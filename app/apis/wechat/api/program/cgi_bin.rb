module Wechat::Api
  module Program::CgiBin
    BASE = 'https://api.weixin.qq.com/wxa/'

    def create_wxa_qrcode(path = '/pages/index/index', width = 430)
      post 'wxaapp/createwxaqrcode', path: path, width: width, base: BASE
    end

  end
end

