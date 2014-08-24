module XeroEngine
  class Organisation < ActiveRecord::Base
    include Stripe::Callbacks

    # AR callbacks
    after_create :after_create_callback
    # after_initialize :after_initialize
    # before_destroy :before_destroy

    # Relationships
    has_many :organisation_memberships
    has_many :users, through: :organisation_memberships
    has_many :billing_transactions, dependent: :destroy
    # has_one :address, as: :addressable, class_name: :Address, dependent: :destroy
    # has_one :print_settings, dependent: :destroy

    # Validations
    validates :name, presence: true

    # Attribtues
    attr_accessor :stripe_token, :coupon

    # Is org actively being used within our app? We can use this information
    # to not include it in backend processes, for instance, since noone's paying
    # for it.
    def active?
      user_ids.any?
    end

    # @return {boolean} Has the user completed the setup wizard for the current org
    def setup_completed?
      furthest_setup_step >= AfterSignupController::STEPS.length - 1
    end

    def has_credit?(cost=0)
      self.credit_amount(false) >= cost
    end

    def credit_amount(completed_only=true)
      cond = completed_only ? { completed: true } : {}
      value = self.billing_transactions.credit.where(cond).sum(:amount_cents) - self.billing_transactions.debit.where(cond).sum(:amount_cents)
      Money.new value, 'USD'
    end

    def debit_amount(options={ this_month: true })
      0
    end

    def has_auto_top_up?
      auto_top_up_amount != nil && auto_top_up_amount > 0
    end

    def stripe_card
      stripe_customer.cards.first if stripe_customer
    end

    def stripe_customer
      @stripe_customer ||=
        begin
          if stripe_customer_id.blank?
            nil
          else
            Stripe::Customer.retrieve(stripe_customer_id)
          end
        rescue Stripe::InvalidRequestError => e
          # Invalid parameters were supplied to Stripe's API
          puts e.inspect
          if e.http_status == 404
            # This customer doesn't exist. We might as well clear it out.
            puts "Clearing 404'd customer record"
            update(stripe_customer_id: nil)
          end
          nil
        rescue => e
          puts e.inspect
          nil
        end
    end

    def create_stripe_customer(created_by, card_stripe_token=nil)
      return stripe_customer if stripe_customer_id

      customer_params = {
        description: "#{name}",
        email: created_by.email,
        card: card_stripe_token,
        metadata: {
          'organisation_id' => id,
          'organisation_name' => name,
          'created_by_user_id' => created_by.id,
          'created_by_user_name' => created_by.name,
          'created_by_user_email' => created_by.email
        }
      }

      customer = Stripe::Customer.create customer_params
      update!(stripe_customer_id: customer.id)

      customer
    end

    def create_stripe_card(stripe_token)
      if stripe_card
        raise "This organisation already has a card ending #{stripe_card['last4']} stored for it. Delete this card before creating a new one."
      else
        stripe_customer.cards.create(:card => stripe_token)
      end
    end

  private

    # AR callbacks

    # def after_initialize
    #   build_address if address.nil?
    # end

    def after_create_callback
      # self.create_print_settings
      OrganisationPostCreationWorker.perform_async(self.short_code)
    end

    # def before_destroy
    #   true # nothing for now
    # end

    # Stripe webhook callbacks

    after_customer_created! do |customer, event|
      # Nothing
    end

    after_customer_deleted! do |customer, event|
      Organisation.find(stripe_customer_id: customer.id).update(stripe_customer_id: nil)
    end

    after_customer_card_deleted! do |customer, event|
      #
    end

    after_customer_card_updated! do |customer, event|
      # Nothing
    end

    after_stripe_event do |target, event|
      Rails.logger.info "Stripe event: \n" + target.inspect + "\n" + event.inspect
    end

  end
end