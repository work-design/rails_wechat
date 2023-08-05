module Wechat::Api
  module Public::Wxopen
    BASE = 'https://api.weixin.qq.com/cgi-bin/wxopen/'

    def wxa_link
      post 'wxamplinkget', origin: BASE
    end

  end
end

