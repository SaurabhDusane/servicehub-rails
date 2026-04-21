module Payments
  # Creates a Stripe PaymentIntent for a booking deposit or full amount.
  # In test/dev without Stripe keys, falls back to a fake succeeded payment.
  class Charger
    Result = Struct.new(:success?, :payment, :client_secret, :errors, keyword_init: true)

    def initialize(booking:, kind: :full)
      @booking = booking
      @kind = kind.to_sym
    end

    def call
      amount_cents = amount_for_kind
      return Result.new(success?: false, errors: ["Nothing to charge"]) if amount_cents.zero?

      if stripe_configured?
        intent = Stripe::PaymentIntent.create(
          amount: amount_cents,
          currency: @booking.currency.downcase,
          metadata: { booking_id: @booking.id, kind: @kind, customer_id: @booking.customer_id },
          automatic_payment_methods: { enabled: true }
        )
        payment = Payment.create!(
          booking: @booking,
          amount_cents: amount_cents,
          currency: @booking.currency,
          kind: @kind,
          status: :pending,
          stripe_payment_intent_id: intent.id,
          metadata: { client_secret: intent.client_secret }
        )
        Result.new(success?: true, payment: payment, client_secret: intent.client_secret, errors: [])
      else
        payment = simulate_payment(amount_cents)
        Result.new(success?: true, payment: payment, client_secret: "test_secret_#{payment.id}", errors: [])
      end
    rescue Stripe::StripeError => e
      Rails.logger.error("[Stripe] #{e.message}")
      Result.new(success?: false, errors: [e.message])
    end

    private

    def amount_for_kind
      case @kind
      when :deposit then @booking.deposit_cents
      when :full    then @booking.price_cents
      when :balance then @booking.balance_due_cents
      else 0
      end
    end

    def stripe_configured?
      key = ENV["STRIPE_SECRET_KEY"].to_s
      key.start_with?("sk_") && key != "sk_test_dummy"
    end

    def simulate_payment(amount_cents)
      payment = Payment.create!(
        booking: @booking,
        amount_cents: amount_cents,
        currency: @booking.currency,
        kind: @kind,
        status: :succeeded,
        stripe_payment_intent_id: "pi_simulated_#{SecureRandom.hex(8)}",
        metadata: { simulated: true }
      )
      Payments::StatusUpdater.new(payment: payment).mark_succeeded!
      payment
    end
  end
end
