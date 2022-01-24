require 'rails_com'
module RailsWechat
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/oauth_user",
      "#{config.root}/app/models/template_config",
      "#{config.root}/app/models/app",
      "#{config.root}/app/models/menu",
      "#{config.root}/app/models/notice",
      "#{config.root}/app/models/reply",
      "#{config.root}/app/models/request",
      "#{config.root}/app/models/service"
    ]
    config.eager_load_paths += Dir[
      "#{config.root}/app/models/oauth_user",
      "#{config.root}/app/models/template_config",
      "#{config.root}/app/models/app",
      "#{config.root}/app/models/menu",
      "#{config.root}/app/models/notice",
      "#{config.root}/app/models/reply",
      "#{config.root}/app/models/request",
      "#{config.root}/app/models/service"
    ]

    config.generators do |g|
      g.rails = {
        assets: false,
        stylesheets: false,
        helper: false,
        system_tests: nil,
        jbuilder: true
      }
      g.resource_route false
      g.test_unit = {
        fixture: true,
        fixture_replacement: :factory_girl
      }
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end

  end
end
