module Wechat
  module Model::CorpExternalUser
    extend ActiveSupport::Concern

    included do
      attribute :uid, :string, index: true
      attribute :unionid, :string, index: true
      attribute :external_userid, :string, index: true
      attribute :pending_id, :string
      attribute :corp_id, :string, index: true

      enum subject_type: {
        oneself: '0',
        provider: '1'
      }

      has_one :corp, primary_key: :corp_id, foreign_key: :corp_id
      has_one :wechat_user, primary_key: :uid, foreign_key: :uid

      before_validation :init_subject_type, if: -> { uid.present? && uid_changed? }
      after_create_commit :get_external_userid_later
    end

    def get_external_userid_later
      CorpExternalUserJob.perform_later(self)
    end

    def init_subject_type
      if wechat_user.app.global
        self.subject_type = :provider
      else
        self.subject_type = :oneself
      end
    end

    def get_external_userid!
      r = corp.get_external_userid(unionid, uid, subject_type: subject_type_before_type_cast.to_i)
      logger.debug "\e[35m  External Userid: #{r}  \e[0m"
      self.external_userid = r['external_userid']
      self.pending_id = r['pending_id']
      self.save
    end

    def get_pending_id!
      r = corp.api.pending_id(external_userid)
      logger.debug "\e[35m  Pending ID: #{r}  \e[0m"
      p = r['result'].find(&->(i){ i['external_userid'] == external_userid })
      return if p.blank?
      self.pending_id = p['pending_id']
      self.save
    end

  end
end

