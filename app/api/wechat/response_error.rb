module Wechat
  class ResponseError < StandardError
    attr_reader :error_code

    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end
end
