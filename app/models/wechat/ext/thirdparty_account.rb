module Wechat
  module Ext::ThirdpartyAccount
    extend ActiveSupport::Concern

    included do
      has_many :corp_users, class_name: 'Wechat::CorpUser', foreign_key: :identity, primary_key: :identity, dependent: :destroy
    end

  end
end
