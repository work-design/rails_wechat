module Wechat
  module Model::CorpExternalUser
    extend ActiveSupport::Concern

    included do
      attribute :uid, :string, index: true
      attribute :unionid, :string, index: true
      attribute :external_userid, :string, index: true
      attribute :provider_external_userid, :string
      attribute :pending_id, :string
      attribute :corp_id, :string, index: true

      has_one :corp, primary_key: :corp_id, foreign_key: :corp_id
      belongs_to :wechat_user, foreign_key: :uid, primary_key: :uid

      after_create_commit :get_external_userid_later
    end

    def get_external_userid_later
      CorpExternalUserJob.perform_later(self)
    end

    def get_external_userid!
      r = corp.get_external_userid(unionid, uid, subject_type: 0)
      logger.debug "\e[35m  External Userid: #{r}  \e[0m"
      self.external_userid = r['external_userid']
      self.pending_id = r['pending_id']

      r1 = corp.get_external_userid(unionid, uid, subject_type: 1)
      logger.debug "\e[35m  Provider External Userid: #{r1}  \e[0m"
      self.provider_external_userid = r1['external_userid']

      self.save
    end

  end
end

