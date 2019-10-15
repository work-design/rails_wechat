module RailsWechat::OauthUser::WechatProgramUser
  extend ActiveSupport::Concern
  included do
    attribute :provider, :string, default: 'wechat_program'
  end
  
end
