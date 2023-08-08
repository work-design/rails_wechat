module Wechat
  module Inner::Menu::ViewMenu
    extend ActiveSupport::Concern

    def as_json(options = {})
      if options[:app]
        host = options[:app].domain.presence || options[:app].organ.host.presence || Rails.application.routes.default_url_options[:host]
      else
        host = app&.domain.presence || organ&.host.prescen || Rails.application.routes.default_url_options[:host]
      end
      r = URI(value)
      r.host ||= host
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
