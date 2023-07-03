# frozen_string_literal: true

module Wechat::Api
  class Program < Base
    include Base::Sns
    include Public::Common
    include Public::Agency
    include Component
    include Sec
    include Wxa
    include Wxaapi
    include Wxaapp
    include Wxopen

    def jscode2session(code)
      if app.is_a?(Wechat::Agency)
        app.platform.api.jscode2session(app.appid, code)
      else
        super
      end
    end

  end
end
