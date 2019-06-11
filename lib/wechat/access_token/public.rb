# frozen_string_literal: true

require_relative 'base'

module Wechat
  module AccessToken
    class Public < Base
      
      def refresh
        data = @client.get('token', params: { grant_type: 'client_credential', appid: @app.appid, secret: @app.secret })
        write_token_to_store(data)
      end
      
    end
  end
end
