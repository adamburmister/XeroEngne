module XeroEngine
  module ApplicationHelper

    # def main_app
    #   Rails.application.class.routes.url_helpers
    # end

    def site_name
      ENV.fetch('SITE_NAME')
    end

    def site_url
      ENV.fetch('SITE_URL')
    end

  end
end
