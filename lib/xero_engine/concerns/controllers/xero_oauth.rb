module XeroEngine::Concerns::Controllers::XeroOauth
  extend ActiveSupport::Concern

  included do
    rescue_from Xeroizer::OAuth::TokenExpired, with: :access_token_expired
    rescue_from Xeroizer::OAuth::TokenInvalid, with: :access_token_invalid
  end

  # Rescue from OAuth errors
  def access_token_expired
    begin
      xero_client.renew_access_token(current_organisation_membership.access_token, 
                                    current_organisation_membership.access_secret, 
                                    current_organisation_membership.session_handle)
    rescue
      if current_organisation?
        current_organisation_membership.update_attributes access_token: nil, access_secret: nil, session_handle: nil
      end

      redirect_to expired_organisation_membership_path(current_organisation_membership)
    end
  end

  def access_token_invalid
    if current_organisation?
      current_organisation_membership.update_attributes access_token: nil, access_secret: nil, session_handle: nil
    end
    if current_organisation_membership
      redirect_to expired_organisation_membership_path(current_organisation_membership), alert: 'There was a problem connecting to Xero'
      return
    else
      redirect_to organisation_memberships_path
    end
  end

end