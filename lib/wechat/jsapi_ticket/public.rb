# frozen_string_literal: true

require_relative 'base'

module Wechat
  module JsapiTicket
    class Public < Base
      
      def refresh
        data = @client.get('ticket/getticket', params: { access_token: @access_token.token, type: 'jsapi' })
        data['oauth2_state'] = SecureRandom.hex(16)
        write_ticket_to_store(data)
      end
      
    end
  end
end
