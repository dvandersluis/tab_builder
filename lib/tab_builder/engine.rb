module TabBuilder
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{ tab_builder.css }
      Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets")
    end
  end
end
