module Wechat
  module Api
  
  end
end
require_relative 'http_client'

require_relative 'token/access_token_base'
require_relative 'token/corp_access_token'
require_relative 'token/public_access_token'

require_relative 'ticket/corp_jsapi_ticket'
require_relative 'ticket/jsapi_base'
require_relative 'ticket/public_jsapi_ticket'

require_relative 'api/base'
require_relative 'api/common'
require_relative 'api/public'
require_relative 'api/program'
require_relative 'api/work'
