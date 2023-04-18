module Wechat::Api
  module Platform::Wxa
    BASE = 'https://api.weixin.qq.com/wxa/'

    def templates
      get 'gettemplatelist', origin: BASE
    end

  end
end
