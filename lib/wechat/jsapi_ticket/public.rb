# frozen_string_literal: true

module Wechat
  module JsapiTicket
    class Public < Base
      BASE = 'https://api.weixin.qq.com/cgi-bin/'

      def refresh
        data = @client.get('ticket/getticket', params: { access_token: @access_token.token, type: 'jsapi' }, base: BASE)
        data['oauth2_state'] = SecureRandom.hex(16)
        write_ticket_to_store(data)
      end

    end
  end
end
