module Wechat
  module Ext::Member
    extend ActiveSupport::Concern
    include Ext::Handle

    included do
      attribute :corp_userid, :string
      attribute :wechat_openid, :string

      belongs_to :wechat_user, class_name: 'Wechat::WechatUser', foreign_key: :wechat_openid, primary_key: :uid, optional: true

      has_many :corp_users, ->(o) { where(organ_id: o.organ_id) }, class_name: 'Wechat::CorpUser', primary_key: :identity, foreign_key: :identity
      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :account, source: :oauth_users
      has_many :program_users, class_name: 'Wechat::ProgramUser', through: :account, source: :oauth_users
      has_many :medias, class_name: 'Wechat::Media'
      has_many :subscribes, -> { where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :program_users
    end

  end
end
