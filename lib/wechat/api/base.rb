# frozen_string_literal: true

module Wechat::Api
  class Base
    attr_reader :app, :client, :access_token, :jsapi_ticket
    MP_BASE = 'https://mp.weixin.qq.com/cgi-bin/'
    
    def callbackip
      get 'getcallbackip'
    end
  
    def qrcode(ticket)
      client.get 'showqrcode', params: { ticket: ticket }, base: MP_BASE, as: :file
    end
  
    def media(media_id)
      get 'media/get', params: { media_id: media_id }, as: :file
    end
  
    def media_hq(media_id)
      get 'media/get/jssdk', params: { media_id: media_id }, as: :file
    end
  
    def media_create(type, file)
      post_file 'media/upload', file, params: { type: type }
    end
  
    def media_uploadimg(file)
      post_file 'media/uploadimg', file
    end
  
    def media_uploadnews(mpnews_message)
      post 'media/uploadnews', mpnews_message
    end
  
    # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1433744592
    def clear_quota(appid)
      post 'clear_quota', { appid: appid }.to_json
    end
  
    protected
    def get(path, params: {}, headers: {}, base: nil, as: nil)
      with_access_token(params) do |with_token_params|
        client.get path, headers: headers, params: with_token_params, base: base, as: as
      end
    end
  
    def post(path, payload, params: {}, headers: {}, base: nil)
      with_access_token(params) do |with_token_params|
        client.post path, payload.to_json, headers: headers, params: with_token_params, base: base
      end
    end
  
    def post_file(path, file, params: {}, headers: {}, base: nil)
      with_access_token(params) do |with_token_params|
        client.post_file path, file, headers: headers, params: with_token_params, base: base
      end
    end
  
    def with_access_token(params = {}, tries = 2)
      yield(params.merge(access_token: access_token.token))
    rescue Wechat::AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end
  end
end
