module Wechat
  module Ext::Profile
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :external_userid, :string
      attribute :position, :string
      attribute :avatar_url, :string
      attribute :corp_name, :string
      attribute :corp_full_name, :string
      attribute :external_type, :string
      attribute :unionid, :string, index: true

      #has_many :follows, ->(o){ where(corp_id: o.corp_id) }, class_name: 'Crm::Maintain', foreign_key: :external_userid, primary_key: :external_userid, inverse_of: :client, dependent: :delete_all
      has_many :wechat_users, class_name: 'Wechat::WechatUser', primary_key: :unionid, foreign_key: :unionid
      has_many :users, class_name: 'Auth::User', through: :wechat_users
      has_many :members, through: :wechat_users

      after_save_commit :sync_related_task_later, if: -> { unionid.present? && saved_change_to_unionid? }
    end

    def sync_related_task_later
      ExternalSyncTaskJob.perform_later(self)
    end

    def sync_related_task
      return if users.blank?
      follows.each do |follow|
        follow.orders.each do |i|
          i.sync_user_from_maintain
        end
      end
    end

  end
end