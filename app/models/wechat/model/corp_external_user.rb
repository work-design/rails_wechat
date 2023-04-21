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
        oneself: 0,
        provider: 1
      }

      has_one :corp, primary_key: :corp_id, foreign_key: :corp_id
      belongs_to :wechat_user, foreign_key: :uid, primary_key: :uid

      before_validation :init_subject_type, if: -> { uid.present? }
      after_create_commit :get_external_userid_later
    end

    def get_external_userid_later
      CorpExternalUserJob.perform_later(self)
    end

    def init_subject_type
      if wechat_user.app.global
        self.subject_type = 1
      else
        self.subject_type = 0
      end
    end

    def get_external_userid!
      r = corp.get_external_userid(unionid, uid, subject_type: subject_type)
      logger.debug "\e[35m  External Userid: #{r}  \e[0m"
      self.external_userid = r['external_userid']
      self.pending_id = r['pending_id']
      self.save
    end

  end
end

