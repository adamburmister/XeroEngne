module XeroEngine::CurrentOrganisation
  extend ActiveSupport::Concern

  included do
    before_filter :redirect_root_to_dashboard
    before_filter :ensure_current_organisation
    helper_method :current_organisation, :current_organisation?, :current_organisation_membership
  end

  # @return {Organisation} current organisation being used to access the Xero API
  def current_organisation
    current_organisation_membership.organisation if has_current_organisation?
  end

  # @return {OrganisationMembership}
  def current_organisation_membership
    @current_organisation_membership ||= if current_user && has_current_organisation?
      org = current_user.organisation_memberships.find_by_short_code current_organisation_short_code
      set_current_organisation_short_code nil if org.nil?
      org
    else
      nil
    end
  end

  # Session state for the current organisation ID
  def current_organisation_short_code
    session[:current_organisation_short_code]
  end

  # Set the sessions state for the current organisation
  def set_current_organisation_short_code(short_code_or_org)
    if short_code_or_org.respond_to? :short_code
      session[:current_organisation_short_code] = short_code_or_org.short_code
    else
      session[:current_organisation_short_code] = short_code_or_org
    end
  end

  # @return {boolean} Has the user picked an Organisation
  def current_organisation?
    user_signed_in? && current_organisation_short_code.present? && current_organisation.present?
  end

  # ---- Filters ----

  def ensure_current_organisation
    if signed_in? && current_user
      if current_organisation_short_code.blank?
        num_of_orgs = current_user.organisation_memberships.size
        if num_of_orgs == 1
          set_current_organisation_short_code current_user.organisation_memberships.first.short_code
        else
          flash[:notice] = "Please pick a Xero Organisation to continue" if num_of_orgs > 1
          redirect_to organisation_memberships_path
        end
      end
    end
  end

  def redirect_root_to_dashboard
    if request.path == '/' && user_signed_in?
      if current_organisation?
        redirect_to dashboard_path
      else
        redirect_to organisation_memberships_path
      end
    end
    false
  end

  private

  def has_current_organisation?
    current_organisation_short_code.present? && current_user && current_user.organisation_memberships.find_by_short_code(current_organisation_short_code).present?
  end

end