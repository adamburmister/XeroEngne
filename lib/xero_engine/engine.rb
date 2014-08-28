module XeroEngine
  class Engine < ::Rails::Engine
    isolate_namespace XeroEngine

    # Skip the ensure_current_org filter within all devise controllers
    config.to_prepare do
      Devise::DeviseController.skip_before_filter :ensure_current_organisation
    end

    config.autoload_paths << File.expand_path('../../', __FILE__)

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
    end

    initializer 'Precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(organisation_memberships.js xero_engine/mailer.css)
    end

    initializer "Require concerns path" do |app|
      [ "app/controllers/concerns",
        "app/workers/concerns",
        "app/models/concerns"
      ].each do |concerns_path|
        unless app.paths.keys.include?(concerns_path)
          app.paths.add(concerns_path)
        end
      end
    end

    initializer 'Add migrations to run' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

  end
end

