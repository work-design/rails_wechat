# frozen_string_literal: true

module Wechat::Api
  class Program < Base
    include Base::Sns
    include Public::Common
    include Public::Agency
    include Wxaapi
    include Wxa
    include CgiBin

    def jscode2session(code)
      if app.is_a?(Wechat::Agency)
        app.platform.api.jscode2session(app.appid, code)
      else
        super
      end
    end

  end
end
