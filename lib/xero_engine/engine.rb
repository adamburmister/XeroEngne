module XeroEngine
  class Engine < ::Rails::Engine

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

    # Autoload from lib directory
    config.autoload_paths << File.expand_path('../../', __FILE__)

    initializer 'Add migrations to run' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

    isolate_namespace XeroEngine
  end
end

