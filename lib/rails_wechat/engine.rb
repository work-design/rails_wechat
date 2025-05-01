require 'rails_com'
module RailsWechat
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/oauth_user",
      "#{config.root}/app/models/template_config",
      "#{config.root}/app/models/app",
      "#{config.root}/app/models/menu",
      "#{config.root}/app/models/menu_app",
      "#{config.root}/app/models/message",
      "#{config.root}/app/models/notice",
      "#{config.root}/app/models/reply",
      "#{config.root}/app/models/request",
      "#{config.root}/app/models/service",
      "#{config.root}/app/models/payee"
    ]
    config.eager_load_paths += Dir[
      "#{config.root}/app/models/oauth_user",
      "#{config.root}/app/models/template_config",
      "#{config.root}/app/models/app",
      "#{config.root}/app/models/menu",
      "#{config.root}/app/models/menu_app",
      "#{config.root}/app/models/message",
      "#{config.root}/app/models/notice",
      "#{config.root}/app/models/reply",
      "#{config.root}/app/models/request",
      "#{config.root}/app/models/service",
      "#{config.root}/app/models/payee"
    ]

    config.generators do |g|
      g.helper false
      g.resource_route false
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end

  end
end
