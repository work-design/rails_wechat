module Wechat
  module Model::Menu::ViewMenu
    extend ActiveSupport::Concern

    included do
      attribute :menu_type, :string, default: 'view'
      after_initialize if: :new_record? do
        self.value ||= host
      end
    end

    def as_json
      {
        type: menu_type,
        name: name,
        url: url
      }
    end

    def url
      ActionDispatch::Http::URL.url_for(
        host: value,
        protocol: Rails.application.routes.default_url_options[:protocol]
      )
    end

    def host
      organ = app&.organ
      if organ
        organ.host
      else
        ''
      end
    end

  end
end
