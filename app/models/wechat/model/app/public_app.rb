module Wechat
  module Model::App::PublicApp

    def sync_templates
      templates = api.templates
      templates.each do |template|
        template = templates.find_or_initialize_by(template_id: template['template_id'])
        template.assign_attributes template.slice('title', 'content', 'example')
        template.save
      end
    end

    def oauth2_url(scope = 'snsapi_userinfo', **host_options)
      h = {
        appid: appid,
        redirect_uri: url_helpers.wechat_app_url(id, **host_options),
        response_type: 'code',
        scope: scope,
        state: SecureRandom.hex(16)
      }
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def generate_wechat_user(code)
      h = {
        appid: appid,
        secret: secret,
        code: code,
        grant_type: 'authorization_code'
      }
      r = HTTPX.get "https://api.weixin.qq.com/sns/oauth2/access_token?#{h.to_query}"
      result = JSON.parse(r.body.to_s)
      wechat_user = wechat_users.find_or_initialize_by(uid: result['openid'])
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user
    end

  end
end
