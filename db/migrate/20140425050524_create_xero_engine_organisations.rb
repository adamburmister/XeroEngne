class CreateXeroEngineOrganisations < ActiveRecord::Migration
  def change
    create_table :xero_engine_organisations do |t|
      # Xero attributes
      t.string   :name, null: false
      t.string   :legal_name
      t.string   :short_code, null: false
      t.string   :version
      t.string   :organisation_type
      t.string   :base_currency
      t.string   :country_code
      t.string   :is_demo_company
      t.string   :organisation_status

      # Xero worker
      t.datetime :last_synced_at

      # Billing
      t.string   :stripe_customer_id
      t.integer  :auto_top_up_amount

      t.timestamps
    end

    add_index :xero_engine_organisations, :short_code, unique: true
    add_index :xero_engine_organisations, :stripe_customer_id, unique: true
  end
end
