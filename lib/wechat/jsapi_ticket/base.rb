# frozen_string_literal: true

require 'digest/sha1'
require 'securerandom'

module Wechat
  module JsapiTicket
    class Base

      def initialize(client, app, access_token)
        @client = client
        @app = app
        @access_token = access_token
      end

      def ticket
        if @app && @app.jsapi_ticket_valid?
          @app.jsapi_ticket
        else
          refresh
        end
      end

      def oauth2_state
        ticket
        @oauth2_state
      end

      # Obtain the wechat jssdk config signature parameter and return below hash
      #  params = {
      #    noncestr: noncestr,
      #    timestamp: timestamp,
      #    jsapi_ticket: ticket,
      #    url: url,
      #    signature: signature
      #  }
      def signature(url)
        params = {
          noncestr: SecureRandom.base64(16),
          timestamp: Time.now.to_i,
          jsapi_ticket: ticket,
          url: url
        }
        pairs = params.keys.sort.map do |key|
          "#{key}=#{params[key]}"
        end
        result = Digest::SHA1.hexdigest pairs.join('&')
        params.merge(signature: result)
      end

      protected
      
      def write_ticket_to_store(ticket_hash)
        if @app
          @app.jsapi_ticket = ticket_hash['ticket']
          @app.jsapi_ticket_expires_at = Time.current + ticket_hash['expires_in'].to_i
          @app.save
          @app.jsapi_ticket
        end
      end
      
    end
  end
end
