module Wechat
  module Ext::Account
    extend ActiveSupport::Concern

    included do
      has_many :corp_users, class_name: 'Wechat::CorpUser', foreign_key: :identity, primary_key: :identity
    end

  end
end
