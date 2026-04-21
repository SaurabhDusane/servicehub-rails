Stripe.api_key = ENV["STRIPE_SECRET_KEY"].presence || "sk_test_dummy"
Stripe.api_version = "2024-06-20"

Rails.application.config.stripe = ActiveSupport::OrderedOptions.new.tap do |c|
  c.publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"].presence || "pk_test_dummy"
  c.webhook_secret  = ENV["STRIPE_WEBHOOK_SECRET"]
end
