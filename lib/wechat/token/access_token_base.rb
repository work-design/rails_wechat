# frozen_string_literal: true

module Wechat
  module Token
    class AccessTokenBase
      
      def initialize(client, app)
        @client = client
        @app = app
      end

      def token
        if @app && @app.access_token_valid?
          @app.access_token
        else
          refresh
        end
      end

      protected
      def write_token_to_store(token_hash)
        raise Wechat::InvalidCredentialError unless token_hash.is_a?(Hash) && token_hash['access_token']
        
        if @app
          @app.access_token = token_hash['access_token']
          @app.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
          @app.save
          @app.access_token
        end
      end
      
    end
  end
end
