module Wechat
  class WechatError < StandardError

    def initialize(msg = nil)
      @msg = msg
    end

  end
end
