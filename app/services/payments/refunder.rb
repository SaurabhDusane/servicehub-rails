module Payments
  class Refunder
    def initialize(booking:, amount_cents:)
      @booking = booking
      @amount_cents = amount_cents.to_i
    end

    def call
      remaining = @amount_cents
      @booking.payments.successful.order(created_at: :asc).each do |payment|
        break if remaining <= 0
        refundable = payment.net_amount_cents
        next if refundable <= 0
        chunk = [refundable, remaining].min
        issue_refund(payment, chunk)
        remaining -= chunk
      end

      paid_total = @booking.total_paid_cents
      new_status = paid_total.zero? ? :refunded : :partially_refunded
      @booking.update!(payment_status: new_status)
    end

    private

    def issue_refund(payment, chunk)
      if stripe_configured? && payment.stripe_payment_intent_id.to_s.start_with?("pi_") && !payment.metadata["simulated"]
        Stripe::Refund.create(payment_intent: payment.stripe_payment_intent_id, amount: chunk)
      end
      payment.update!(
        refunded_amount_cents: payment.refunded_amount_cents + chunk,
        status: payment.net_amount_cents - chunk <= 0 ? :refunded : :partially_refunded
      )
    end

    def stripe_configured?
      ENV["STRIPE_SECRET_KEY"].to_s.start_with?("sk_") && ENV["STRIPE_SECRET_KEY"] != "sk_test_dummy"
    end
  end
end
