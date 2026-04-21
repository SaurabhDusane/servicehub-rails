module Payments
  class StatusUpdater
    def initialize(payment:)
      @payment = payment
      @booking = payment.booking
    end

    def mark_succeeded!(charge_id: nil, receipt_url: nil)
      ActiveRecord::Base.transaction do
        @payment.update!(status: :succeeded, stripe_charge_id: charge_id, receipt_url: receipt_url)
        sync_booking_payment_status!
        @booking.update!(confirmed_at: Time.current, status: :confirmed) if @booking.pending? && @booking.service.instant_booking?
        AuditLog.record!(action: "payment.succeeded", user: @booking.customer, target: @payment,
                         payload: { amount_cents: @payment.amount_cents })
        BookingMailer.payment_confirmation(@booking.id, @payment.id).deliver_later
      end
    end

    def mark_failed!(reason: nil)
      @payment.update!(status: :failed, metadata: @payment.metadata.merge("failure_reason" => reason))
      @booking.update!(payment_status: :failed)
      AuditLog.record!(action: "payment.failed", user: @booking.customer, target: @payment, payload: { reason: reason })
    end

    def sync_booking_payment_status!
      paid = @booking.total_paid_cents
      new_status =
        if paid >= @booking.price_cents
          :paid
        elsif paid >= @booking.deposit_cents && @booking.deposit_cents.positive?
          :deposit_paid
        else
          :unpaid
        end
      @booking.update!(payment_status: new_status)
    end
  end
end
