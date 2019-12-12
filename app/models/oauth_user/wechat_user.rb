class WechatUser < OauthUser
  include RailsWechat::OauthUser::WechatUser
end unless defined? WechatUser
