module Wechat
  class WechatProgramUser < Auth::WechatUser
    include RailsWechat::OauthUser::WechatProgramUser
  end
end
