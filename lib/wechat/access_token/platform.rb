# frozen_string_literal: true

module Wechat
  module AccessToken
    class Platform < Base

      def refresh
        data = @client.get('token', params: { grant_type: 'client_credential', appid: @app.appid, secret: @app.secret })
        write_token_to_store(data)
      end

    end
  end
end
