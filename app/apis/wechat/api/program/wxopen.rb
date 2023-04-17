module Wechat::Api
  module Program::Wxopen
    BASE = 'https://api.weixin.qq.com/cgi-bin/wxopen/'

    def category
      get 'getcategory', origin: BASE
    end

  end
end

