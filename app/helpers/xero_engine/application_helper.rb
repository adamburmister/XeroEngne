module XeroEngine
  module ApplicationHelper

    # def main_app
    #   Rails.application.class.routes.url_helpers
    # end

    def site_name
      ENV.fetch('SITE_NAME') || '[.env SITE_NAME not set]'
    end

  end
end
