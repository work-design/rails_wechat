module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      attribute :corp_id, :string

      has_many :apps, class_name: 'Wechat::App', dependent: :destroy_async
      belongs_to :corp, class_name: 'Wechat::Corp', foreign_key: :corp_id, primary_key: :corp_id, optional: true
      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true

      validates :limit_wechat_menu, inclusion: { in: [1, 2, 3] }
    end

    def contact
      return @contact if defined? @contact
      if corp_user
        @contact ||= corp_user.contacts.find_or_create_by(state: '外部联系')
      end
    end

  end
end
