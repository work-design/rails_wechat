module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      attribute :corpid, :string

      has_many :apps, class_name: 'Wechat::App', dependent: :destroy_async
      has_many :provider_organs, class_name: 'Wechat::ProviderOrgan', primary_key: :corpid, foreign_key: :corpid
      has_many :corps, class_name: 'Wechat::Corp', through: :provider_organs

      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true

      validates :limit_wechat_menu, inclusion: { in: [0, 1, 2, 3] }

      after_save_commit :compute_open_corpid, if: -> { saved_change_to_corpid? }
    end

    def contact
      return @contact if defined? @contact
      if corp_user
        @contact ||= corp_user.contacts.find_or_create_by(state: '外部联系')
      end
    end

    def compute_open_corpid
      Provider.find_each do |i|
        provider_organs.find_or_create_by(provider_id: i.id)
      end
    end

  end
end
