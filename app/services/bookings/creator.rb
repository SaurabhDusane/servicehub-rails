module Bookings
  # Creates a booking transactionally, preventing double-booking via DB exclusion constraint.
  class Creator
    Result = Struct.new(:success?, :booking, :errors, keyword_init: true)

    def initialize(customer:, service:, start_time:, notes: nil, timezone: nil)
      @customer   = customer
      @service    = service
      @provider   = service.provider_profile
      @start_time = start_time.is_a?(Time) ? start_time : Time.zone.parse(start_time.to_s)
      @notes      = notes
      @timezone   = timezone.presence || @customer.timezone
    end

    def call
      end_time = @start_time + @service.duration_minutes.minutes

      booking = Booking.new(
        customer: @customer,
        provider_profile: @provider,
        service: @service,
        start_time: @start_time,
        end_time: end_time,
        timezone: @timezone,
        price_cents: @service.price_cents,
        deposit_cents: @service.deposit_cents,
        currency: @service.currency,
        notes: @notes,
        status: initial_status
      )

      ActiveRecord::Base.transaction do
        booking.save!
        AuditLog.record!(action: "booking.created", user: @customer, target: booking,
                         payload: { status: booking.status, amount_cents: booking.price_cents })
        BookingMailer.confirmation(booking.id).deliver_later
        NotifyProviderJob.perform_later(booking.id, "new_booking")
      end

      Result.new(success?: true, booking: booking, errors: [])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, booking: e.record, errors: e.record.errors.full_messages)
    rescue ActiveRecord::StatementInvalid => e
      # Exclusion constraint violation -> overlapping booking
      if e.message.include?("no_overlapping_bookings")
        booking.errors.add(:start_time, :overlap)
        Result.new(success?: false, booking: booking, errors: booking.errors.full_messages)
      else
        raise
      end
    end

    private

    def initial_status
      @service.instant_booking? && !@service.requires_approval? ? :confirmed : :pending
    end
  end
end
