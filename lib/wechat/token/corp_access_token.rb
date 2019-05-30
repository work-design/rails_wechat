# frozen_string_literal: true

require 'wechat/token/access_token_base'

module Wechat
  module Token
    class CorpAccessToken < AccessTokenBase
      
      def refresh
        data = @client.get('gettoken', params: { corpid: @app.appid, corpsecret: @app.secret })
        write_token_to_store(data)
      end
      
    end
  end
end
