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
      attribute :remark_mobiles, :json, default: []

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true

      after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
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

  end
end
