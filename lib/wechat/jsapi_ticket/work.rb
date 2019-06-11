# frozen_string_literal: true

require_relative 'base'

module Wechat
  module JsapiTicket
    class Work < Base
      
      def refresh
        data = @client.get('get_jsapi_ticket', params: { access_token: access_token.token })
        data['oauth2_state'] = SecureRandom.hex(16)
        write_ticket_to_store(data)
      end
      
    end
  end
end
