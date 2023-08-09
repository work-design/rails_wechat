module Wechat
  module Model::App
    SERVICE_TYPE = {
      '0' => 'WechatRead',
      '1' => 'WechatRead',
      '2' => 'WechatPublic'
    }.freeze
    extend ActiveSupport::Concern
    include Inner::Token
    include Inner::JsToken

    included do
      attribute :type, :string
      attribute :appid, :string
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
      attribute :extra, :json
      attribute :version_info, :json, default: {}
      attribute :logo_media_id, :string
      attribute :enabled, :boolean, default: true
      attribute :global, :boolean, default: false
      attribute :oauth_enable, :boolean, default: true
      attribute :secret, :string
      attribute :token, :string
      attribute :encrypt_mode, :boolean, default: true
      attribute :encoding_aes_key, :string
      attribute :url_link, :string
      attribute :debug, :boolean, default: false

      encrypts :secret

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :platform, optional: true

      #has_many :post_syncs, as: :synced, dependent: :delete_all
      #has_many :posts, through: :post_syncs

      has_many :services, primary_key: :appid, foreign_key: :appid
      has_many :scenes, primary_key: :appid, foreign_key: :appid, inverse_of: :app
      has_many :tags, primary_key: :appid, foreign_key: :appid
      has_many :templates, primary_key: :appid, foreign_key: :appid
      has_many :app_configs, primary_key: :appid, foreign_key: :appid
      has_many :menu_apps, -> { where(scene_id: nil) }, primary_key: :appid, foreign_key: :appid
      has_many :all_menu_apps, class_name: 'MenuApp', primary_key: :appid, foreign_key: :appid
      has_many :menu_root_apps, primary_key: :appid, foreign_key: :appid
      has_many :receives, primary_key: :appid, foreign_key: :appid
      has_many :replies, primary_key: :appid, foreign_key: :appid
      has_many :requests, primary_key: :appid, foreign_key: :appid
      has_many :responses, primary_key: :appid, foreign_key: :appid
      has_many :wechat_users, primary_key: :appid, foreign_key: :appid
      has_many :payee_apps, primary_key: :appid, foreign_key: :appid
      has_many :payees, through: :payee_apps

      has_one_attached :file
      has_one_attached :logo

      scope :enabled, -> { where(enabled: true) }
      scope :inviting, -> { where(inviting: true) }
      scope :global,  -> { where(global: true) }

      validates :appid, presence: true, uniqueness: true


      before_validation :init_token, if: -> { token.blank? }
      before_validation :init_aes_key, if: -> { encrypt_mode && encoding_aes_key.blank? }
      after_update :set_global, if: -> { global? && saved_change_to_global? }
      after_create_commit :store_info_later
      after_save_commit :sync_to_storage, if: -> { saved_change_to_qrcode_url? }
    end

    def decrypt(encrypt_data)
      Wechat::Cipher.decrypt(encrypt_data, encoding_aes_key)
    end

    def init_token
      self.token = SecureRandom.hex
    end

    def init_aes_key
      self.encoding_aes_key = SecureRandom.alphanumeric(43)
    end

    def url
      Rails.application.routes.url_for(controller: 'wechat/apps', action: 'show', id: self.id, host: domain) if domain.present?
    end

    def sync_menu
      api.menu_delete
      api.menu_create menu
    end

    def menu_roots
      r = MenuRoot.includes(:menus).order(position: :asc).to_a
      menu_root_apps.includes(:menu_root).order(position: :desc).each do |menu_root_app|
        if menu_root_app.menu_root
          r.insert r.index(menu_root_app.menu_root) + 1, menu_root_app
        else
          r.insert -(r.size + 1), menu_root_app
        end
      end
      r
    end

    def menu
      r = menu_roots.map do |menu_root|
        if menu_root.is_a?(MenuRoot)
          subs = menu_root.app_menus(appid)[0..4].as_json(host: domain.split(':')[0])
        else
          subs = menu_apps[0..5].as_json(host: domain.split(':')[0])
        end

        if subs.size <= 1
          subs[0]
        else
          { name: menu_root.name, sub_button: subs }
        end
      end.compact

      { button: r[0..2] }
    end


    def oauth2_qrcode_url(**host_options)
      q = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/apps', action: 'show', id: id, **host_options),
        scope: 'snsapi_login',
        response_type: 'code',
        state: SecureRandom.hex(16)
      }

      "https://open.weixin.qq.com/connect/qrconnect?#{q.to_query}#wechat_redirect"
    end

    def sync_tags
      results = api.tags
      results.fetch('tags', []).each do |result|
        tag = tags.find_or_initialize_by(name: result['name'])
        tag.count = result['count']
        tag.tag_id = result['id']
        tag.save
      end
      tags.where(tag_id: nil).each do |tag|
        tag.sync_to_wechat_later
      end
    end

    def base64_state(host: self.domain, controller_path: '/home', action_name: 'index', method: 'get', **params)
      state = Com::State.create(
        host: host,
        controller_path: controller_path,
        action_name: action_name,
        request_method: method.downcase,
        params: params
      )
      state.id
    end

    def sync_from_menu
      r = api.menu
      present_menus = r.dig('menu', 'button')
      present_menus.each_with_index do |present_menu, index|
        if present_menu['sub_button'].present?
          parent = self.pure_menu_roots.find_or_initialize_by(position: index + 1)
          parent.name = present_menu['name']
          present_menu['sub_button'].each_with_index do |sub, sub_index|
            m = parent.menus.find_or_initialize_by(appid: appid, position: sub_index + 1)
            m.name = sub['name']
            m.type = Menu::TYPE[sub['type']]
            m.value = sub['url'] || sub['key']
          end
          parent.save
        else
          m = menus.find_or_initialize_by(root_position: index + 1)
          m.type = Menu::TYPE[sub['type']]
          m.name = present_menu['name']
          m.value = present_menu['url'] || present_menu['key']
          m.save
        end
      end
    end

    def sync_templates
      api.templates.each do |temp|
        template = templates.find_or_initialize_by(template_id: temp['template_id'])
        template.assign_attributes temp.slice('title', 'content', 'example')
        template.save
      end
    end

    def template_ids(notifiable_type, *code)
      ids = TemplateConfig.where(notifiable_type: notifiable_type, code: code).pluck(:id)
      templates.where(template_config_id: ids).pluck(:template_id)
    end

    def set_global
      self.class.where.not(id: self.id).global.update_all(global: false)
    end

    def name
      nick_name.presence || user_name
    end

    def disabled_func_infos
    end

    def refresh_access_token
      r = platform.api.authorizer_token(appid, refresh_token)
      store_access_token(r)
    end

    def generate_wechat_user(code)
      result = platform.api.oauth2_access_token(code, appid)
      logger.debug "\e[35m  Agency generate User: #{result}  \e[0m"

      wechat_user = WechatUser.find_or_initialize_by(uid: result['openid'])
      wechat_user.appid = appid
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'scope', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user.agency_oauth = true
      wechat_user.init_user
      wechat_user
    end

    def store_info_later
      AgencyJob.perform_later(self)
    end

    def store_info!
      r = platform.api.get_authorizer_info(appid)
      logger.debug "\e[35m  Agency Store Info: #{r}  \e[0m"
      return if r.blank?
      self.assign_attributes r.slice('nick_name', 'head_img', 'user_name', 'principal_name', 'qrcode_url', 'business_info')
      self.alias_name = r['alias']
      self.service_type = r.dig('service_type_info', 'id')
      self.verify_type = r.dig('verify_type_info', 'id')
      self.extra = r
      if r['MiniProgramInfo'].present?
        self.type = 'Wechat::ProgramAgency'
      else
        self.type = 'Wechat::PublicAgency'
      end
      self.save
    end

    def store_access_token(r)
      self.access_token = r['authorizer_access_token']
      self.access_token_expires_at = Time.current + r['expires_in'].to_i
      self.refresh_token = r['authorizer_refresh_token']
      self.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') } if r['func_info'].is_a?(Array)
      self.save
    end

    def sync_to_storage
      self.file.url_sync(qrcode_url)
    end

    def upload_logo
      r = logo.blob.open do |file|
        api.media_create file
      end
      self.update logo_media_id: r['media_id']
      api.modify_logo(logo_media_id)
    end

    def upload_desc
      api.modify_desc("#{organ.name}官方小程序")
    end

  end
end
