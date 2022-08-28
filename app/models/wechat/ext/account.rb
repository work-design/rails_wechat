module Wechat
  module Ext::Account
    extend ActiveSupport::Concern

    included do
      has_many :corp_users, class_name: 'Wechat::CorpUser', primary_key: :identity, foreign_key: :identity, inverse_of: :account
      has_many :wechat_users, class_name: 'Wechat::WechatUser', primary_key: :identity, foreign_key: :identity
      #has_many :externals, class_name: 'Wechat::External', through: :wechat_users
    end

  end
end
