module RailsWechat::WechatApp::WechatPublic
  extend ActiveSupport::Concern
  included do

  end

  def sync_wechat_templates
    templates = api.templates
    templates.each do |template|
      wechat_template = wechat_templates.find_or_initialize_by(template_id: template['template_id'])
      wechat_template.assign_attributes template.slice('title', 'content', 'example')
      wechat_template.save
    end
  end

  def oauth2_url
    "https://open.weixin.qq.com/connect/oauth2/authorize?#{oauth2_params.to_query}#wechat_redirect"
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
    wechat_user.access_token = result.slice('access_token', 'refresh_token', 'unionid')
    wechat_user.expires_at = Time.current + result['expires_in']
    wechat_user
  end

end
