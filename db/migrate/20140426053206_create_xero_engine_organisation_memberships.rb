class CreateXeroEngineOrganisationMemberships < ActiveRecord::Migration
  def change
    create_table :xero_engine_organisation_memberships do |t|
      t.integer :organisation_id
      t.integer :user_id
      t.string :short_code
      t.string :access_token
      t.string :access_secret
      t.string :session_handle
      t.datetime :expires_at
      t.datetime :authorization_expires_at

      t.timestamps
    end
    add_index :xero_engine_organisation_memberships, :short_code
    add_index :xero_engine_organisation_memberships, :organisation_id
    add_index :xero_engine_organisation_memberships, :user_id
    add_index :xero_engine_organisation_memberships, :session_handle
  end
end
