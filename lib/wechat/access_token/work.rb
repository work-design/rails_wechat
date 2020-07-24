# frozen_string_literal: true

module Wechat
  module AccessToken
    class Work < Base

      def refresh
        data = @client.get('gettoken', params: { corpid: @app.appid, corpsecret: @app.secret })
        write_token_to_store(data)
      end

    end
  end
end
