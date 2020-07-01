class WechatUser < OauthUser
  include RailsAuth::OauthUser::WechatUser
  include RailsWechat::OauthUser::WechatUser
end unless defined? WechatUser
