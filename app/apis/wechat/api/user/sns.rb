module Wechat::Api
  module User::Sns
    BASE = 'https://api.weixin.qq.com/sns/'

    def userinfo(openid)
      get 'userinfo', params: { openid: openid }, origin: BASE
    end

  end
end
