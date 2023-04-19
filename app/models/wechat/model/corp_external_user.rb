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
    end

    def get_external_userid!(corp: get_corp, subject_type: 0)
      r = corp.get_external_userid(unionid, uid, corp: corp, subject_type: subject_type)
      logger.debug "\e[35m  External Userid: #{r}  \e[0m"
      self.external_userid = r['external_userid']
      self.pending_id = r['pending_id']
      self.save
    end

  end
end

