module Wechat
  class ProgramUser < WechatUser
    include Model::OauthUser::ProgramUser
  end
end
