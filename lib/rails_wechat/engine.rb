require 'rails_com'
module RailsWechat
  class Engine < ::Rails::Engine
    
    config.autoload_paths += Dir[
      "#{config.root}/app/models/wechat_menu",
      "#{config.root}/app/models/wechat_request",
      "#{config.root}/app/models/wechat_response",
      "#{config.root}/app/models/wechat_app"
    ]
    
    config.generators do |g|
      g.rails = {
        assets: false,
        stylesheets: false,
        helper: false,
        jbuilder: true
      }
      g.test_unit = {
        fixture: true,
        fixture_replacement: :factory_girl
      }
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end
  
    initializer 'rails_wechat.assets.precompile' do |app|
      app.config.assets.precompile += ['rails_wechat_manifest.js']
    end

    initializer 'rails_wechat.zeitwerk.preload' do |app|
      Rails.autoloaders.main&.preload "#{config.root}/app/models/wechat_response/persist_scan_response.rb"
      Rails.autoloaders.main&.preload "#{config.root}/app/models/wechat_response/temp_scan_response.rb"
    end
    
  end
end
