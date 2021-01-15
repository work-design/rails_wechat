module Wechat
  class WechatUser < Auth::OauthUser
    include RailsWechat::OauthUser::WechatUser
  end
end
