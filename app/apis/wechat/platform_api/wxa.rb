class Wechat::PlatformApi
  module Wxa
    BASE = 'https://api.weixin.qq.com/wxa/'

    def templates
      get 'gettemplatelist', origin: BASE
    end

  end
end
