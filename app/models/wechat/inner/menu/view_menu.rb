module Wechat
  module Inner::Menu::ViewMenu
    extend ActiveSupport::Concern

    def as_json(options = {})
      if value.to_s.start_with?('/')
        r = URI(value)
      else
        r = URI("/#{value}")
      end
      r.host ||= options[:host]
      r.scheme = Rails.application.routes.default_url_options[:protocol].presence || 'https'
      r.to_s

      {
        type: 'view',
        name: name,
        url: r.to_s
      }
    end

  end
end
