class WechatProgramUser < OauthUser
  include RailsWechat::OauthUser::WechatProgramUser
end unless defined? WechatProgramUser
