module Wechat
  module Api
  
  end
end
require_relative 'http_client'

require_relative 'access_token/base'
require_relative 'access_token/work'
require_relative 'access_token/public'

require_relative 'jsapi_ticket/base'
require_relative 'jsapi_ticket/work'
require_relative 'jsapi_ticket/public'

require_relative 'api/base'
require_relative 'api/common'
require_relative 'api/public'
require_relative 'api/program'
require_relative 'api/work'
