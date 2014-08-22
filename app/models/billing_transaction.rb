class BillingTransaction < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :organisation
  belongs_to :created_by, class_name: 'User'

  # When we create this model attempt to raise the charge with Stripe
  before_create :attempt_charge

  monetize :amount_cents
  
  enum transaction_type: [ :credit, :debit ]

  attr_accessor :auto_top_up

  validates :created_by, presence: true
  # validates :lob_job_id, presence: {
  #   if: Proc.new{|t| t.debit?},
  #   message: 'must have an associated print job ID'
  # }
  # validates :stripe_charge_id, presence: {
  #   if: Proc.new{|t| t.credit?},
  #   message: 'must have an associated stripe charge id'
  # }

  def self.credits
    where(transaction_type: 0).order(created_at: :desc)
  end

  def self.debits
    where(transaction_type: 1).order(created_at: :desc)
  end

  def lob_job
    PrintService.job(lob_job_id)  
  end

  def stripe_charge
    Stripe::Charge.retrieve(stripe_charge_id)
  end

  def stripe_charge=(charge)
    self.stripe_charge_id = charge.id
  end

  # Create the charge on Stripe's servers - this will charge the user's card
  def attempt_charge
    self.stripe_charge = create_stripe_charge
  end

  private

  # @return {Stripe::Charge}
  def create_stripe_charge
    if stripe_charge_id && stripe_charge.paid
      logger.error "Charge #{stripe_charge_id} already paid"
      errors.add(:base, 'This billing transaction has already been charged successfully')
      return
    end

    charge = nil

    begin
      charge_params = {
        customer: organisation.stripe_customer.id,
        amount: self.amount_cents, # amount in cents, again
        currency: self.amount_currency,
        description: self.organisation.name
      }
      logger.info "Creating charge #{charge_params.inspect}"
      charge = Stripe::Charge.create charge_params
    rescue Stripe::CardError => e
      # The card has been declined
      errors.add(:base, e)

      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]

      logger.debug "Status is: #{e.http_status}"
      logger.debug "Type is: #{err[:type]}"
      logger.debug "Code is: #{err[:code]}"
      # param is '' in this case
      logger.debug "Param is: #{err[:param]}"
      logger.debug "Message is: #{err[:message]}"

      errors.add(:base, err[:message])
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
      logger.error e.inspect
      errors.add(:base, "There was a problem connecting to the payment service. Please send customer support an email at #{ENV.fetch('CUSTOMER_SUPPORT_EMAIL')}")
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
      logger.error e.inspect
      errors.add(:base, "There was a problem connecting to the payment service. Please send customer support an email at #{ENV.fetch('CUSTOMER_SUPPORT_EMAIL')}")
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      logger.error e.inspect
      errors.add(:base, "There was a problem connecting to the payment service. Please send customer support an email at #{ENV.fetch('CUSTOMER_SUPPORT_EMAIL')}")
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
      logger.error e.inspect
      errors.add(:base, "There was a problem connecting to the payment service. Please send customer support an email at #{ENV.fetch('CUSTOMER_SUPPORT_EMAIL')}")
    end

    charge
  end

  # Webhook callbacks

  after_charge_succeeded! do |charge|
    billing_transaction = BillingTransaction.find_by_stripe_charge_id(charge.id)
    if billing_transaction.credit?
      organisation = billing_transaction.organisation
      logger.info "Charge succeeded for customer #{organisation.name} (#{organisation.id}), amount of $#{charge.amount / 100} (#{charge.id})"
      billing_transaction.update(completed: charge.paid)
    end
  end

  after_charge_failed! do |charge|
    billing_transaction = BillingTransaction.find_by_stripe_charge_id(charge.id)
    if billing_transaction.credit?
      logger.info "Charge failed for customer #{organisation.name} (#{organisation.id}), amount of $#{charge.amount / 100} (#{charge.id})"
      billing_transaction.update(completed: charge.paid)
    end
  end

end
