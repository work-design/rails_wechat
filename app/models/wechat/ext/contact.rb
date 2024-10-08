module Wechat
  module Ext::Contact
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
      attribute :wechat_openid, :string, index: true

      has_many :union_wechat_users, class_name: 'Auth::OauthUser', primary_key: :unionid, foreign_key: :unionid
      has_many :corp_external_users, -> { where.not(external_userid: nil) }, class_name: 'Wechat::CorpExternalUser', primary_key: :external_userid, foreign_key: :external_userid
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
        self.client_user_id = union_wechat_users.pluck(:user_id).compact[0]
      else
        self.client_user_id = wechat_users.pluck(:user_id).compact[0]
      end

      self.save
    end

  end
end
