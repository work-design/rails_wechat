module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      attribute :appid, :string

      belongs_to :app, class_name: 'Wechat::App', foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :agency, class_name: 'Wechat::Agency', foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true

      has_many :apps, class_name: 'Wechat::App', dependent: :destroy_async
      has_many :agencies, class_name: 'Wechat::App'
      has_many :corps, class_name: 'Wechat::Corp', dependent: :nullify

      validates :limit_wechat_menu, inclusion: { in: [0, 1, 2, 3] }
    end

    def contact
      return @contact if defined? @contact
      if corp_user
        @contact ||= corp_user.contacts.find_or_create_by(state: '外部联系')
      end
    end

  end
end
