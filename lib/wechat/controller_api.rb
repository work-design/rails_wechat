module Wechat
  module ControllerApi

    def wechat_oauth2(account, scope = 'snsapi_base', page_url = nil, &block)
      api = Wechat.api(account)
      app = Wechat.config(account)
      
      oauth2_params = {
        appid: app.appid,
        redirect_uri: page_url || generate_redirect_uri(account),
        scope: scope,
        response_type: 'code',
        state: api.jsapi_ticket.oauth2_state
      }

      return generate_oauth2_url(oauth2_params) unless block_given?
      is_crop_account ? wechat_corp_oauth2(oauth2_params, account, &block) : wechat_public_oauth2(oauth2_params, account, &block)
    end

    private
    def wechat_public_oauth2(oauth2_params, account = nil)
      openid = cookies.signed_or_encrypted[:we_openid]
      unionid = cookies.signed_or_encrypted[:we_unionid]
      we_token = cookies.signed_or_encrypted[:we_access_token]
      if openid.present?
        yield openid, { 'openid' => openid, 'unionid' => unionid, 'access_token' => we_token}
      elsif params[:code].present? && params[:state] == oauth2_params[:state]
        access_info = wechat(account).web_access_token(params[:code])
        cookies.signed_or_encrypted[:we_openid] = { value: access_info['openid'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_unionid] = { value: access_info['unionid'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_access_token] = { value: access_info['access_token'], expires: self.class.oauth2_cookie_duration.from_now }
        yield access_info['openid'], access_info
      else
        redirect_to generate_oauth2_url(oauth2_params)
      end
    end

    def wechat_corp_oauth2(oauth2_params, account = nil)
      userid   = cookies.signed_or_encrypted[:we_userid]
      deviceid = cookies.signed_or_encrypted[:we_deviceid]
      if userid.present? && deviceid.present?
        yield userid, { 'UserId' => userid, 'DeviceId' => deviceid }
      elsif params[:code].present? && params[:state] == oauth2_params[:state]
        userinfo = wechat(account).getuserinfo(params[:code])
        cookies.signed_or_encrypted[:we_userid] = { value: userinfo['UserId'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_deviceid] = { value: userinfo['DeviceId'], expires: self.class.oauth2_cookie_duration.from_now }
        yield userinfo['UserId'], userinfo
      else
        redirect_to generate_oauth2_url(oauth2_params)
      end
    end

    def generate_redirect_uri(account = nil)
      domain_name = Wechat.config(account).trusted_domain_fullname
      page_url = domain_name ? "#{domain_name}#{request.original_fullpath}" : request.original_url
      safe_query = request.query_parameters.except('code', 'state', 'access_token').to_query
      page_url.sub(request.query_string, safe_query)
    end

    def generate_oauth2_url(oauth2_params)
      if oauth2_params[:scope] == 'snsapi_login'
        "https://open.weixin.qq.com/connect/qrconnect?#{oauth2_params.to_query}#wechat_redirect"
      else
        "https://open.weixin.qq.com/connect/oauth2/authorize?#{oauth2_params.to_query}#wechat_redirect"
      end
    end
    
  end
end
