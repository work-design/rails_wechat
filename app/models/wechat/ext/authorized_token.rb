module Wechat
  module Ext::AuthorizedToken
    extend ActiveSupport::Concern

    included do
      attribute :suite_id, :string
      attribute :appid, :string

      belongs_to :corp_user, -> (o){ where(suite_id: o.suite_id) }, class_name: 'Wechat::CorpUser', foreign_key: :identity, primary_key: :identity, optional: true
      belongs_to :app, class_name: 'Wechat::App', foreign_key: :appid, primary_key: :appid, optional: true
    end

    def filter_hash
      {
        uid: self.uid,
        session_key: self.session_key,
        session_id: self.session_id,
        appid: self.appid,
        suite_id: self.suite_id
      }
    end

  end
end
