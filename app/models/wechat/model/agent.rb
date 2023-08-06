module Wechat
  module Model::Agent
    extend ActiveSupport::Concern
    include Inner::Token
    include Inner::JsToken

    included do
      attribute :name, :string
      attribute :inviting, :boolean, default: false, comment: '可邀请加入'
      attribute :corpid, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :agentid, :string
      attribute :encoding_aes_key, :string
      attribute :user_name, :string
      attribute :domain, :string
      attribute :url_link, :string
      attribute :debug, :boolean, default: false
      attribute :confirm_name, :string
      attribute :confirm_content, :string

      validates :agentid, presence: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :corp_users, ->(o){ where(suite_id: nil, organ_id: o.organ_id) }, primary_key: :corpid, foreign_key: :corpid
      has_many :suite_receives, ->(o){ where(agent_id: o.agentid) }, primary_key: :corpid, foreign_key: :corpid

      before_validation :init_token, if: -> { token.blank? }
      before_validation :init_aes_key, if: -> { encoding_aes_key.blank? }
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Work.new(self)
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

    def init_corp
      self.organ.update corp_id: self.corpid
    end

    def url
      Rails.application.routes.url_for(controller: 'wechat/agents', action: 'create', id: self.id, host: domain) if domain.present?
    end

    def sync_departments
      r = api.department
      return unless r['errcode'] == 0
      r['department'].each do |dep|
        depart = organ.departments.find_or_initialize_by(wechat_id: dep['id'])
        depart.name = dep['name']
        depart.save
      end
    end

    def js_login(**url_options)
      url_options.with_defaults! controller: 'wechat/agents', action: 'login', id: id, host: self.domain
      {
        appid: corpid,
        agentid: agentid,
        redirect_uri: ERB::Util.url_encode(Rails.application.routes.url_for(**url_options)),
        state: Com::State.create(host: domain, controller_path: '/me/home').id
      }
    end

    def oauth2_url(scope: 'snsapi_privateinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/agents', action: 'login', id: id, host: self.domain
      h = {
        appid: corpid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state,
        agentid: agentid
      }
      logger.debug "\e[35m  Oauth2 Options: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def generate_corp_user(code)
      result = api.getuserinfo(code)
      logger.debug "\e[35m  gene corp User: #{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(userid: result['UserId'])
      corp_user.device_id = result['DeviceId'] if result['DeviceId'].present?
      corp_user.user_ticket = result['user_ticket']
      corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
      corp_user
    end

  end
end
