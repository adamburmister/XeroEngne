module XeroEngine
  class Engine < ::Rails::Engine

    initializer "xero_engine.include_concerns" do
      ActiveSupport.on_load(:action_controller) do
        include Concerns::Controllers
      end
      ActiveSupport.on_load(:active_record) do
        include Concerns::Models
      end
    end

    # Autoload from lib directory
    config.autoload_paths << File.expand_path('../../', __FILE__)

    initializer 'xero_engine.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

    isolate_namespace XeroEngine
  end
end

