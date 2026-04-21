module Bookings
  class Canceller
    Result = Struct.new(:success?, :booking, :refund_cents, :errors, keyword_init: true)

    def initialize(booking:, actor:, reason: nil)
      @booking = booking
      @actor   = actor
      @reason  = reason
    end

    def call
      unless cancellable?
        return Result.new(success?: false, booking: @booking, refund_cents: 0,
                          errors: ["Booking cannot be cancelled at this time."])
      end

      refund_cents = calculate_refund

      ActiveRecord::Base.transaction do
        @booking.update!(
          status: :cancelled,
          cancelled_at: Time.current,
          cancelled_by: @actor,
          cancellation_reason: @reason
        )

        if refund_cents.positive?
          Payments::Refunder.new(booking: @booking, amount_cents: refund_cents).call
        end

        AuditLog.record!(action: "booking.cancelled", user: @actor, target: @booking,
                         payload: { refund_cents: refund_cents, reason: @reason })

        BookingMailer.cancelled(@booking.id).deliver_later
      end

      Result.new(success?: true, booking: @booking, refund_cents: refund_cents, errors: [])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, booking: @booking, refund_cents: 0, errors: e.record.errors.full_messages)
    end

    private

    def cancellable?
      return false unless Booking::CANCELLABLE_BY_CUSTOMER.include?(@booking.status)
      return true if @actor&.admin?
      return true if @actor == @booking.provider_profile.user
      @booking.cancellable_by_customer?
    end

    def calculate_refund
      cutoff = @booking.provider_profile.cancellation_cutoff_hours.to_i.hours
      if (@booking.start_time - Time.current) > cutoff || @actor&.admin? || @actor == @booking.provider_profile.user
        @booking.total_paid_cents
      else
        0
      end
    end
  end
end
