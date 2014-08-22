module XeroEngine::Concerns::Controllers::SetupWizard
  extend ActiveSupport::Concern
  included do
    before_filter :ensure_setup_wizard_completed
    helper_method :setup_completed?
  end

  # ---- Filters ----

  def ensure_setup_wizard_completed
    if user_signed_in? && !current_organisation.setup_completed?
      redirect_to after_signup_path(Wicked::FIRST_STEP)
    end
  end

end