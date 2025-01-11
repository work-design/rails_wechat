# frozen_string_literal: true
require 'httpx'
require 'http/form_data'

module Wechat
  class BaseApi
    include CommonApi

    protected
    def with_access_token(params: {}, headers: {}, tries: 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

    def parse_response(response)
      if response.respond_to?(:status)
        if response.status != 200
          raise "Request get fail, response status #{response}"
        end
      else

      end
      content_type = response.content_type.mime_type

      if content_type =~ /image|audio|video/
        data = Tempfile.new('tmp')
        data.binmode
        data.write(response.body.to_s)
        data.rewind
        return data
      elsif content_type =~ /html|xml/
        data = Hash.from_xml(response.body.to_s)
      elsif content_type =~ /json/
        Rails.logger.debug "----------#{response.body.to_s}"
        data = response.json
      else
        data = JSON.parse(response.body.to_s)
      end

      case data['errcode']
      when 0
        data
        # 42001: access_token timeout
        # 40014: invalid access_token
        # 40001, invalid credential, access_token is invalid or not latest hint
        # 48001, api unauthorized hint, should not handle here # GH-230
        # 40082, 企业微信
      when 42001, 40014, 40001, 41001, 40082
        raise Wechat::AccessTokenExpiredError, data
      else
        data
      end
    end

  end
end
