module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      attribute :appid, :string

      belongs_to :app, class_name: 'Wechat::App', foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true

      has_many :apps, class_name: 'Wechat::App'
      has_many :corps, class_name: 'Wechat::Corp'
      has_many :payees, class_name: 'Wechat::Payee'
      has_many :scenes, as: :handle, class_name: 'Wechat::Scene'

      validates :limit_wechat_menu, inclusion: { in: [0, 1, 2, 3] }
    end

    def invite_member!
      app = provider&.app

      if app
        scene = scenes.find_or_initialize_by(appid: app.appid, organ_id: id, aim: 'invite_member')
        scene.check_refresh
        scene.save
        scene
      end
    end

    def contact
      return @contact if defined? @contact
      if corp_user
        @contact ||= corp_user.contacts.find_or_create_by(state: '外部联系')
      end
    end

  end
end
