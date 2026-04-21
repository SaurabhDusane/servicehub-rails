module Webhooks
  class StripeController < ActionController::API
    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      secret = Rails.application.config.stripe.webhook_secret

      event =
        if secret.present?
          Stripe::Webhook.construct_event(payload, sig_header, secret)
        else
          JSON.parse(payload, symbolize_names: true)
        end

      handle(event)
      head :ok
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.warn("[StripeWebhook] #{e.class}: #{e.message}")
      head :bad_request
    end

    private

    def handle(event)
      type = event.is_a?(Hash) ? event[:type] : event.type
      data = event.is_a?(Hash) ? event[:data][:object] : event.data.object

      case type
      when "payment_intent.succeeded"
        payment = Payment.find_by(stripe_payment_intent_id: data[:id] || data.id)
        Payments::StatusUpdater.new(payment: payment).mark_succeeded!(charge_id: data[:latest_charge]) if payment
      when "payment_intent.payment_failed"
        payment = Payment.find_by(stripe_payment_intent_id: data[:id] || data.id)
        Payments::StatusUpdater.new(payment: payment).mark_failed!(reason: data[:last_payment_error]&.dig(:message)) if payment
      when "charge.refunded"
        # handled by the Refunder service in-app; nothing required here.
      end
    end
  end
end
