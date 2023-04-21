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
      has_many :corp_external_users, class_name: 'Wechat::CorpExternalUser', primary_key: :external_userid, foreign_key: :external_userid

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

    def get_corp
      Corp.where(organ_id: organ.self_and_ancestor_ids).take
    end

    def init_corp_external_user(corp: get_corp)
      return unless corp
      corp_external_users.present? || corp_external_users.create(corp_id: corp.corp_id)
    end

  end
end
