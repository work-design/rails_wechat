# frozen_string_literal: true

module Wechat
  class ProgramApi < BaseApi
    include Base::Sns
    include Public::Common
    include Public::Agency
    include Public::Material
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
