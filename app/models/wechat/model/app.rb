module Wechat
  module Model::App
    extend ActiveSupport::Concern

    included do
      attribute :type, :string, default: 'Wechat::PublicApp'
      attribute :name, :string
      attribute :enabled, :boolean, default: true
      attribute :shared, :boolean, default: false, comment: '可与其他或下级机构公用'
      attribute :global, :boolean, default: false
      attribute :oauth_enable, :boolean, default: true
      attribute :inviting, :boolean, default: false, comment: '可邀请加入'
      attribute :appid, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :agentid, :string, comment: '企业微信所用'
      attribute :encrypt_mode, :boolean, default: true
      attribute :encoding_aes_key, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :jsapi_ticket, :string
      attribute :oauth2_state, :string
      attribute :jsapi_ticket_expires_at, :datetime
      attribute :user_name, :string
      attribute :domain, :string
      attribute :url_link, :string
      attribute :app_payees_count, :integer, default: 0
      attribute :debug, :boolean, default: false

      encrypts :secret

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      #has_many :post_syncs, as: :synced, dependent: :delete_all
      #has_many :posts, through: :post_syncs

      has_one :organ_domain, -> { where(default: true) }, class_name: 'Org::OrganDomain', primary_key: :domain, foreign_key: :identifier
      has_many :organ_domains, class_name: 'Org::OrganDomain', primary_key: :domain, foreign_key: :identifier

      has_one :agency, primary_key: :appid, foreign_key: :appid
      has_many :agencies, primary_key: :appid, foreign_key: :appid
      has_many :scenes, primary_key: :appid, foreign_key: :appid, inverse_of: :app
      has_many :tags, primary_key: :appid, foreign_key: :appid
      has_many :templates, primary_key: :appid, foreign_key: :appid
      has_many :app_configs, primary_key: :appid, foreign_key: :appid
      has_many :app_payees, primary_key: :appid, foreign_key: :appid
      has_many :payees, through: :app_payees

      scope :enabled, -> { where(enabled: true) }
      scope :shared, -> { where(shared: true) }
      scope :inviting, -> { where(inviting: true) }
      scope :global,  -> { where(global: true) }

      validates :appid, presence: true, uniqueness: true

      before_validation :init_token, if: -> { token.blank? }
      before_validation :init_aes_key, if: -> { encrypt_mode && encoding_aes_key.blank? }
      after_update :set_global, if: -> { global? && saved_change_to_global? }
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
      r = MenuRoot.where(organ_id: [nil, organ_id], appid: [nil, appid]).order(position: :asc)
      r.group_by(&:position).transform_values! do |x|
        x.find(&->(i){ i.appid == appid }) || x.find(&->(i){ i.organ_id == organ_id }) || x.find(&->(i){ i.organ_id.nil? })
      end.values
    end

    def menu
      r = menu_roots.map do |menu_root|
        subs = menu_root.menus.where(organ_id: [organ_id, nil], appid: [appid, nil]).limit(5).as_json

        if subs.size <= 1
          subs[0]
        else
          { name: menu_root.name, sub_button: subs }
        end
      end

      { button: r }
    end

    def refresh_access_token
      r = api.token
      if r['access_token']
        store_access_token(r)
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def store_access_token(token_hash)
      self.access_token = token_hash['access_token']
      self.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
      self.save
    end

    def jsapi_ticket_valid?
      return false unless jsapi_ticket_expires_at.acts_like?(:time)
      jsapi_ticket_expires_at > Time.current
    end

    def refresh_jsapi_ticket
      r = api.jsapi_ticket
      store_jsapi_ticket(r)
      jsapi_ticket
    end

    def store_jsapi_ticket(ticket_hash)
      self.jsapi_ticket = ticket_hash['ticket']
      self.jsapi_ticket_expires_at = Time.current + ticket_hash['expires_in'].to_i
      self.save
    end

    def api
      return @api if defined? @api
      if secret.present?
        @api = Wechat::Api::Public.new(self)
      elsif agency
        @api = Wechat::Api::Public.new(agency)
      else
        raise 'Must has secret or under agency'
      end
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
      state = [
        host,
        controller_path,
        action_name,
        method.downcase,
        params.to_query
      ]

      logger.debug "\e[35m  state: #{state}  \e[0m"
      state.map! { |i| Base64.urlsafe_encode64(i, padding: false) }
      state.join('~')
    end

    def sync_templates
      puts 'should implement in sub models'
    end

    def template_ids(notifiable_type, *code)
      ids = TemplateConfig.where(notifiable_type: notifiable_type, code: code).pluck(:id)
      templates.where(template_config_id: ids).pluck(:template_id)
    end

    def set_global
      self.class.where.not(id: self.id).global.update_all(global: false)
    end

    def agent
      agentid.present? && self
    end

  end
end
