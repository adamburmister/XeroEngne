module XeroEngine
  class BillingTransactionsController < AuthorisedController

    # skip_before_filter :warn_no_stripe_card_payment_method
    # before_filter :disable_caching

    def index
      flash.delete(:warning) if flash[:warning]
      @credit_transactions = current_organisation.billing_transactions.credits.limit(10)
      @credit_transaction = current_organisation.billing_transactions.new transaction_type: :credit, created_by: current_user, amount_cents: 0
    end

    # def new
    #   @credit_transaction = current_organisation.billing_transactions.new transaction_type: :credit, created_by: current_user, amount_cents: 0
    # end

    def create
      @credit_transaction = current_organisation.billing_transactions.new(
          transaction_type: :credit,
          created_by: current_user,
          amount_cents: billing_transaction_params[:amount_cents].to_i
      )

      if @credit_transaction.save
        if billing_transaction_params[:auto_top_up]
          current_organisation.update(auto_top_up_amount: billing_transaction_params[:amount_cents])
        end

        flash[:success] = I18n.t 'billing_transaction.creation.success', amount: @credit_transaction.amount, :scope => [:xero_engine]
        redirect_to @credit_transaction
      else
        message = I18n.t 'billing_transaction.creation.error', :scope => [:xero_engine]
        redirect_to :back, alert: message
      end
    end

    def show
      @credit_transaction = current_organisation.billing_transactions.credits.find(params[:id])
    end

    def billing_transaction_params
      params.require(:billing_transaction).permit(:amount_cents, :auto_top_up)
    end

  end
end