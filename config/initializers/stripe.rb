require "stripe"

Stripe.api_key = Rails.application.secrets.stripe_secret

Rails.application.configure do
  config.stripe.publishable_key = Rails.application.secrets.stripe_public
end
