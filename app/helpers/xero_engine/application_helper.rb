module XeroEngine
  module ApplicationHelper

    @@head_stylesheets = []

    # def main_app
    #   Rails.application.class.routes.url_helpers
    # end

    def site_name
      ENV.fetch('SITE_NAME')
    end

    def site_url
      ENV.fetch('SITE_URL')
    end

    def head_stylesheet_tag(url)
      @@head_stylesheets << url
    end

    def head_stylesheet_tags
      @@head_stylesheets.map do |url|
        stylesheet_link_tag url
      end.join("\n").html_safe
    end

  end
end
