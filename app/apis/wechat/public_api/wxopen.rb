class Wechat::PublicApi
  module Wxopen
    BASE = 'https://api.weixin.qq.com/cgi-bin/wxopen/'

    def wxa_link
      post 'wxamplinkget', origin: BASE
    end

  end
end

