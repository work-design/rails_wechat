module Wechat
  module Model::MenuApp
    extend ActiveSupport::Concern
    include Inner::Menu

    included do
      attribute :appid, :string, index: true
      attribute :position, :integer

      belongs_to :menu, optional: true
      belongs_to :menu_root, optional: true
      belongs_to :menu_root_app, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      belongs_to :scene, optional: true
      belongs_to :tag, optional: true

      acts_as_list scope: [:menu_id, :appid]

      before_validation :sync_menu_root, if: -> { menu_id_changed? }
    end

    def sync_menu_root
      self.menu_root_id = menu&.menu_root_id
    end

    def xx
      if options[:app]
        host = options[:app].domain.presence || options[:app].organ.host.presence || Rails.application.routes.default_url_options[:host]
      else
        host = app&.domain.presence || organ&.host.prescen || Rails.application.routes.default_url_options[:host]
      end
    end

  end
end
