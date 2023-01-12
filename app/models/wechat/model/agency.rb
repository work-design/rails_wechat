module Wechat
  module Model::Agency
    SERVICE_TYPE = {
      '0' => 'WechatRead',
      '1' => 'WechatRead',
      '2' => 'WechatPublic'
    }.freeze
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :refresh_token, :string
      attribute :func_infos, :string, array: true
      attribute :nick_name, :string
      attribute :head_img, :string
      attribute :user_name, :string
      attribute :principal_name, :string
      attribute :alias_name, :string
      attribute :qrcode_url, :string
      attribute :business_info, :json
      attribute :service_type, :string
      attribute :verify_type, :string
      attribute :default, :boolean, default: false

      belongs_to :platform
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      has_many :services, primary_key: :appid, foreign_key: :appid

      has_one_attached :file

      after_create_commit :store_info_later
      before_save :init_app, if: -> { appid_changed? && appid }
      after_update :set_default, if: -> { default? && saved_change_to_default? }
      after_save_commit :sync_to_storage, if: -> { saved_change_to_qrcode_url? }
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Public.new(self)
    end

    def init_app
      app || build_app(name: nick_name)
      app.save
    end

    def disabled_func_infos
      return unless platform.agency
      platform.agency.func_infos - func_infos
    end

    def refresh_access_token
      r = platform.api.authorizer_token(appid, refresh_token)
      store_access_token(r)
    end

    def oauth2_url(scope: 'snsapi_base', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', id: app.id, host: platform.domain
      h = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state,
        component_appid: platform.appid
      }
      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def generate_wechat_user(code)
      result = platform.api.oauth2_access_token(code)
      logger.debug "\e[35m  Detail: #{result}  \e[0m"

      wechat_user = WechatUser.find_or_initialize_by(uid: result['openid'])
      wechat_user.appid = appid
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user.sync_user_info if wechat_user.access_token.present? && (wechat_user.attributes['name'].blank? && wechat_user.attributes['avatar_url'].blank?)
      wechat_user
    end

    def store_info_later
      AgencyJob.perform_later(self)
    end

    def store_info
      r = platform.api.get_authorizer_info(appid)
      self.assign_attributes r.slice('nick_name', 'head_img', 'user_name', 'principal_name', 'qrcode_url', 'business_info')
      self.alias_name = r['alias']
      self.service_type = r.dig('service_type_info', 'id')
      self.verify_type = r.dig('verify_type_info', 'id')
      self.save
    end

    def store_access_token(r)
      self.access_token = r['authorizer_access_token']
      self.access_token_expires_at = Time.current + r['expires_in'].to_i
      self.refresh_token = r['authorizer_refresh_token']
      self.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') } if r['func_info'].is_a?(Array)
      self.save
    end

    def set_default
      self.class.where.not(id: self.id).where(platform_id: self.platform_id).update_all(default: false)
    end

    def sync_to_storage
      self.file.url_sync(qrcode_url)
    end

  end
end
