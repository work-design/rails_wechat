module Wechat
  module Ext::Profile
    extend ActiveSupport::Concern

    included do
      attribute :corpid, :string
      attribute :external_userid, :string
      attribute :position, :string
      attribute :avatar_url, :string
      attribute :corp_name, :string
      attribute :corp_full_name, :string
      attribute :external_type, :string
      attribute :unionid, :string, index: true

      has_many :union_wechat_users, class_name: 'Wechat::WechatUser', primary_key: :unionid, foreign_key: :unionid
      has_many :corp_external_users, class_name: 'Wechat::CorpExternalUser', primary_key: :external_userid, foreign_key: :external_userid
      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :corp_external_users
      has_many :users, class_name: 'Auth::User', through: :wechat_users
      has_many :wechat_members, class_name: 'Org::Member', through: :wechat_users

      after_save_commit :sync_related_task_later, if: -> { unionid.present? && saved_change_to_unionid? }
    end

    def sync_related_task_later
      ExternalSyncTaskJob.perform_later(self)
    end

    def sync_related_task
      if union_wechat_users.present?
        self.user_id = union_wechat_users.pluck(:user_id).compact[0]
      else
        self.user_id = wechat_users.pluck(:user_id).compact[0]
      end
      client_maintains.each do |maintain|
        maintain.sync_user_from_client
      end

      self.class.transaction do
        self.save
        client_maintains.each(&:save)
      end
    end

  end
end
