module Wechat
  module Ext::Maintain
    extend ActiveSupport::Concern

    included do
      attribute :type, :string

      attribute :remark, :string
      attribute :state, :string
      attribute :oper_userid, :string
      attribute :add_way, :string
      attribute :external_userid, :string
      attribute :pending_id, :string, index: true
      attribute :remark_mobiles, :json, default: []

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true

      has_many :corp_external_users, class_name: 'Wechat::CorpExternalUser', primary_key: :external_userid, foreign_key: :external_userid
      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :corp_external_users
      has_many :users, class_name: 'Auth::User', through: :wechat_users
      has_many :pending_external_users, class_name: 'Wechat::CorpExternalUser', primary_key: :pending_id, foreign_key: :pending_id

      after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
      after_save_commit :get_pending_id_later, if: -> { external_userid.present? && saved_change_to_external_userid? }
    end

    def sync_remark_later
      MaintainSyncRemarkJob.perform_later(self)
    end

    def sync_remark_to_api
      return if member.corp_users.blank?
      member.corp_users.each do |corp_user|
        app = corp_user.corp || corp_user.app.agent
        next if app.blank?
        r = app.api.remark(corp_user.user_id, external_userid, remark: remark)
        logger.debug "\e[35m  sync Remark: #{r}  \e[0m"
        break
      end
    end

    def get_pending_id_later
      MaintainSyncPendingJob.perform_later(self)
    end

    def get_corp
      Corp.where(organ_id: organ.self_and_ancestor_ids).take
    end

    def get_pending_id!(corp: get_corp)
      return unless corp
      r = corp.api.pending_id(external_userid)
      logger.debug "\e[35m  Pending ID: #{r}  \e[0m"
      p = r['result'].find(&->(i){ i['external_userid'] == external_userid })
      return if p.blank?
      self.pending_id = p['pending_id']
      self.save
    end

  end
end
