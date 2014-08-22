module XeroEngine
  class ApplicationController < ActionController::Base

    include CurrentOrganisation

    helper XeroEngine::ApplicationHelper

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # Prevent a page from being cached by calling this
    def disable_caching
      expires_now
    end

  end
end
