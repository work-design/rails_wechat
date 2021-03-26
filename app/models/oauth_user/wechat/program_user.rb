module Wechat
  class ProgramUser < ::Auth::WechatUser
    include Model::OauthUser::ProgramUser
  end
end
