# frozen_string_literal: true

module Wechat
  module AccessToken
    class Public < Base
      BASE = 'https://api.weixin.qq.com/cgi-bin/'

      def refresh
        data = @client.get('token', params: { grant_type: 'client_credential', appid: @app.appid, secret: @app.secret }, base: BASE)
        write_token_to_store(data)
      end

    end
  end
end
