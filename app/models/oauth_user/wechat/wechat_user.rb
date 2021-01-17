module Wechat
  class WechatUser < Auth::OauthUser
    include Model::OauthUser::WechatUser
  end
end
