module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1

      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true

      has_one :app, ->{ where(type: ['Wechat::PublicApp', 'Wechat::PublicAgency']) }, class_name: 'Wechat::App'
      has_many :apps, class_name: 'Wechat::App'
      has_many :corps, class_name: 'Wechat::Corp'

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
