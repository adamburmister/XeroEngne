module XeroEngine
  class PaymentMethodsController < ApplicationController

    skip_before_filter :warn_no_stripe_card_payment_method
    before_filter :disable_caching

    def create
      if current_organisation.stripe_customer.nil?
        # There is no customer yet, so create one, passing in the card that way
        current_organisation.create_stripe_customer(current_user, params[:stripeToken])
      else
        # The customer already exists, so just create it using the .card access path
        current_organisation.create_stripe_card(params[:stripeToken])
      end

      flash[:success] = "You have successfully added a new payment method to your account."
      redirect_to :back
    end

    def destroy
      current_organisation.stripe_card.delete if current_organisation.stripe_card
      flash[:success] = "You have successfully removed the previous payment method."
      redirect_to :back
    end

  end
end