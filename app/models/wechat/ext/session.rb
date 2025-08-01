module Wechat
  module Ext::Session
    extend ActiveSupport::Concern

    included do
      attribute :suite_id, :string
      attribute :corp_userid, :string
      attribute :appid, :string

      belongs_to :corp_user, -> (o){ where(suite_id: o.suite_id, corpid: o.appid) }, class_name: 'Wechat::CorpUser', foreign_key: :corp_userid, primary_key: :userid, optional: true
      belongs_to :app, class_name: 'Wechat::App', foreign_key: :appid, primary_key: :appid, optional: true
    end

    def filter_hash
      {
        uid: self.uid,
        session_id: self.session_id,
        appid: self.appid,
        suite_id: self.suite_id
      }
    end

  end
end
