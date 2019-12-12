class WechatUser < OauthUser
  include RailsAuth::OauthUser::WechatUser
end unless defined? WechatUser
