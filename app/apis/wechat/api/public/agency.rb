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

    def open_bind(open_appid)
      post 'open/bind', open_appid: open_appid, origin: BASE
    end

    def open_unbind(open_appid)
      post 'open/unbind', open_appid: open_appid, origin: BASE
    end

    def fast_register(ticket)
      post 'account/fastregister', ticket: ticket, origin: BASE
    end

  end
end
