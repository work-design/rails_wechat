module Wechat
  module Ext::User
    extend ActiveSupport::Concern
    include Ext::Handle

    included do
      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :accounts, source: :oauth_users
      has_many :program_users, class_name: 'Wechat::ProgramUser', through: :accounts, source: :oauth_users
      has_many :medias, class_name: 'Wechat::Media'
      has_many :subscribes, ->{ where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :program_users
    end

  end
end
