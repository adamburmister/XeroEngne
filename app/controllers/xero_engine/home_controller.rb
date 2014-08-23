module XeroEngine
  class HomeController < ApplicationController

    # Render the marketing page, or if logged in go to the dashboard
    def index
      if user_signed_in?
        unless current_organisation?
          redirect_to organisation_memberships_path
        else
          redirect_to dashboard_path
        end
      end
    end

  end
end