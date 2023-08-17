module Wechat
  module Model::Suite
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string
      attribute :suite_id, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :suite_ticket, :string
      attribute :suite_ticket_pre, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :pre_auth_code, :string
      attribute :pre_auth_code_expires_at, :datetime
      attribute :redirect_controller, :string
      attribute :redirect_action, :string, default: 'index', comment: '默认跳转'

      enum kind: {
        develop: 'develop',
        install: 'install'
      }, _default: 'develop', _prefix: true

      belongs_to :provider, foreign_key: :corp_id, primary_key: :corp_id

      has_many :suite_receives, primary_key: :suite_id, foreign_key: :suiteid
      has_many :corp_users, primary_key: :suite_id, foreign_key: :suite_id
      has_many :corps, primary_key: :suite_id, foreign_key: :suite_id

      before_validation :init_aes_key, if: -> { encoding_aes_key.blank? || token.blank? }
    end

    def init_aes_key
      self.token = token.presence || SecureRandom.alphanumeric(24)
      self.encoding_aes_key = encoding_aes_key.presence || SecureRandom.alphanumeric(43)
    end

    def decrypt(msg)
      Wechat::Cipher.decrypt(msg, encoding_aes_key)
    end

    def url
      Rails.application.routes.url_for(controller: 'wechat/suites', action: 'notify', id: self.id)
    end

    def oauth2_url(scope: 'snsapi_userinfo', host:, **url_options)
      state_model = Com::State.create(
        host: host,
        controller_path: redirect_controller,
        action_name: redirect_action
      )
      url_options.with_defaults! controller: 'wechat/suites', action: 'login', id: id, host: host
      h = {
        appid: suite_id,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state_model.id
      }

      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def install_url(state: SecureRandom.hex(16), host:, **host_options)
      refresh_pre_auth_code unless pre_auth_code_valid?
      h = {
        suite_id: suite_id,
        pre_auth_code: pre_auth_code,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/providers', action: 'login', id: id, host: host, **host_options),
        state: state
      }

      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.work.weixin.qq.com/3rdapp/install?#{h.to_query}"
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Suite.new(self)
    end

    def refresh_pre_auth_code
      r = api.pre_auth_code
      if r['pre_auth_code']
        self.pre_auth_code = r['pre_auth_code']
        self.pre_auth_code_expires_at = Time.current + r['expires_in'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def pre_auth_code_valid?
      return false unless pre_auth_code_expires_at.acts_like?(:time)
      pre_auth_code_expires_at > Time.current
    end

    def refresh_access_token
      r = api.token
      if r['suite_access_token']
        self.access_token = r['suite_access_token']
        self.access_token_expires_at = Time.current + r['expires_in'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def generate_corp_user(code)
      result = api.auth_user(code)
      logger.debug "\e[35m  Suite CorpUser#{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(open_userid: result['open_userid'])
      corp_user.corp_id = result['corpid']
      corp_user.userid = result['userid']
      corp_user.user_ticket = result['user_ticket']
      corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
      corp_user.open_id = result['openid']
      corp_user
    end

    def generate_corp(auth_code)
      r = api.permanent_code(auth_code)
      logger.debug "\e[35m  Generate Corp: #{r}  \e[0m"
      return if r['errcode']

      corp_id = r.dig('auth_corp_info', 'corpid')
      open = provider.api.open_corpid(corp_id)
      logger.debug "\e[35m  Suite Corp Open id: #{open}  \e[0m"

      corp = corps.find_or_initialize_by(corpid: corp_id)
      corp.open_corpid = open['open_corpid']
      corp.assign_info(r)
      corp.save
      corp
    end

  end
end
