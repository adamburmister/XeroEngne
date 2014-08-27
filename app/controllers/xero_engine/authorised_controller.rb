module XeroEngine
  class AuthorisedController < ApplicationController

    # Concerns
    include Pundit
    include XeroClient
    include XeroOauth

    # Filters
    before_filter :authenticate_user!,
                  :ensure_current_organisation,
                  :warn_no_stripe_card_payment_method

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # Rescue from Pundit auth errors
    def user_not_authorized
      redirect_to request.referrer || root_url, alert: 'Access denied'
    end

    def warn_no_stripe_card_payment_method
      if current_organisation? && current_organisation.stripe_card.nil?
        flash[:warning] = I18n.t 'xero_engine.payment_method.missing'
      end
    end

  end
end