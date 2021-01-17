module Wechat
  class WechatProgramUser < Auth::WechatUser
    include Model::OauthUser::WechatProgramUser
  end
end
