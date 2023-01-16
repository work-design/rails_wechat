module Wechat
  module Model::App::PublicApp
    extend ActiveSupport::Concern

    included do
      attribute :weapp_id, :string, comment: '关联的小程序'

      belongs_to :weapp, class_name: 'ProgramApp', foreign_key: :weapp_id, primary_key: :appid, optional: true
    end

    def js_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      js_hash = Wechat::Signature.signature(jsapi_ticket, url)
      js_hash.merge! appid: appid
      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

    def sync_templates
      api.templates.each do |temp|
        template = templates.find_or_initialize_by(template_id: temp['template_id'])
        template.assign_attributes temp.slice('title', 'content', 'example')
        template.save
      end
    end

    def oauth2_url(scope: 'snsapi_base', state: SecureRandom.hex(16), **url_options)
      return agency.oauth2_url(scope: scope, state: state, **url_options) if agency
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', id: id, host: self.domain
      h = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state
      }
      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def oauth2_data_url(scope = 'snsapi_base', **host_options)
      r = oauth2_url(scope: scope, **host_options)
      QrcodeHelper.data_url(r)
    end

    def generate_wechat_user(code)
      result = api.oauth2_access_token(code)
      logger.debug "\e[35m  Detail: #{result}  \e[0m"

      wechat_user = WechatUser.find_or_initialize_by(uid: result['openid'])
      wechat_user.appid = appid
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user.sync_user_info if wechat_user.access_token.present? && (wechat_user.attributes['name'].blank? && wechat_user.attributes['avatar_url'].blank?)
      wechat_user
    end

  end
end
