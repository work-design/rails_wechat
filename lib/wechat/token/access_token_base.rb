# frozen_string_literal: true

module Wechat
  module Token
    class AccessTokenBase
      
      def initialize(client, app)
        @client = client
        @wechat_config = app
      end

      def token
        if @wechat_config && @wechat_config.access_token_valid?
          @wechat_config.access_token
        else
          refresh
        end
      end

      protected
      def write_token_to_store(token_hash)
        raise InvalidCredentialError unless token_hash.is_a?(Hash) && token_hash['access_token']
        
        if @wechat_config
          @wechat_config.access_token = token_hash['access_token']
          @wechat_config.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
          @wechat_config.save
          @wechat_config.access_token
        end
      end
      
    end
  end
end
