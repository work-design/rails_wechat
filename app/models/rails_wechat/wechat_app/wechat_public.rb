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


end
