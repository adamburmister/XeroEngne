class CreateXeroEngineBillingTransactions < ActiveRecord::Migration
  def change
    create_table :xero_engine_billing_transactions do |t|
      t.integer :organisation_id, null: false
      t.integer :created_by_id, null: false
      t.string :stripe_charge_id
      t.integer :transaction_type, default: 0, null: false
      t.money :amount, default: 0
      t.boolean :completed, default: false
      t.string :description, null: true
      t.timestamps
    end

    add_index :xero_engine_billing_transactions, :stripe_charge_id
    add_index :xero_engine_billing_transactions, :created_by_id
  end
end
