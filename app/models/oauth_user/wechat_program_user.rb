class WechatProgramUser < WechatUser
  include RailsWechat::OauthUser::WechatProgramUser
end unless defined? WechatProgramUser
