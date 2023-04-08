# frozen_string_literal: true

module Wechat::Api
  module Public::Agency
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def open_create
      post 'open/create', origin: BASE
    end

    def open_get
      post 'open/get', origin: BASE
    end

  end
end
