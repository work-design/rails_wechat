module Wechat
  class WechatError < StandardError; end
  class AccessTokenExpiredError < WechatError; end
  class InvalidCredentialError < WechatError; end
  class AppNotFound < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end
end
