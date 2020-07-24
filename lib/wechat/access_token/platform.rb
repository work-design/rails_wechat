# frozen_string_literal: true

module Wechat
  module AccessToken
    class Platform < Base
      BASE = 'https://api.weixin.qq.com/cgi-bin/component/'

      def refresh
        data = @client.get(
          'api_component_token',
          params: {
            component_appid: @app.appid,
            component_appsecret: @app.secret,
            component_verify_ticket: @app.verify_ticket
          },
          base: BASE
        )
        write_token_to_store(data)
      end

      def write_token_to_store(token_hash)
        unless token_hash.is_a?(Hash) && token_hash['component_access_token']
          raise Wechat::InvalidCredentialError, token_hash['errmsg']
        end

        if @app
          @app.access_token = token_hash['component_access_token']
          @app.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
          @app.save
          @app.access_token
        end
      end

    end
  end
end
