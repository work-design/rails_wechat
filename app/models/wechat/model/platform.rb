module Wechat
  module Model::Platform
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :appid, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :verify_ticket, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :pre_auth_code, :string
      attribute :pre_auth_code_expires_at, :datetime
      attribute :domain, :string

      belongs_to :public_agency, optional: true
      belongs_to :program_agency, optional: true

      has_many :agencies
      has_many :auths
      has_many :platform_tickets, primary_key: :appid, foreign_key: :appid
      has_many :receives, dependent: :nullify
      has_many :platform_templates, autosave: true

      before_validation :init_token, if: -> { token.blank? }
      before_validation :init_aes_key, if: -> { encoding_aes_key.blank? }
    end

    def init_token
      self.token = SecureRandom.hex
    end

    def init_aes_key
      self.encoding_aes_key = SecureRandom.alphanumeric(43)
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Platform.new(self)
    end

    def decrypt(encrypt_data)
      Wechat::Cipher.decrypt(encrypt_data, encoding_aes_key)
    end

    def refresh_pre_auth_code
      token_hash = api.create_preauthcode
      if token_hash.is_a?(Hash) && token_hash['pre_auth_code']
        self.pre_auth_code = token_hash['pre_auth_code']
        self.pre_auth_code_expires_at = Time.current + token_hash['expires_in'].to_i
        self.save
      else
        raise Wechat::InvalidCredentialError, Hash(token_hash)['errmsg']
      end
    end

    def sync_templates
      r = api.templates
      rs = r['template_list'].map do |item|
        t = platform_templates.find_or_initialize_by(template_id: item['template_id'])
        t.assign_attributes item.slice('user_version', 'user_desc', 'audit_status')
        t.created_at = Time.at(item['create_time'])
        t
      end
      self.save
      rs
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def pre_auth_code_valid?
      return false unless pre_auth_code_expires_at.acts_like?(:time)
      pre_auth_code_expires_at > 3.minutes.since
    end

    def refresh_access_token
      r = api.component_token
      store_access_token(r)
      r
    end

    def store_access_token(token_hash)
      self.access_token = token_hash['component_access_token']
      self.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
      self.save
    end

    def auth_url
      return if verify_ticket.blank?
      refresh_pre_auth_code unless pre_auth_code_valid?
      url = URI('https://mp.weixin.qq.com/dashboard/cgi-bin/componentloginpage')
      url.query = {
        component_appid: appid,
        pre_auth_code: pre_auth_code,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/platforms', action: 'callback', id: self.id, host: domain)
      }.to_query
      url.to_s
    end

    def click_auth_url
      return if verify_ticket.blank?
      refresh_pre_auth_code unless pre_auth_code_valid?
      url = URI('https://open.weixin.qq.com/wxaopen/safe/bindcomponent')
      url.query = {
        action: 'bindcomponent',
        no_scan: 1,
        auth_type: 3,
        component_appid: appid,
        pre_auth_code: pre_auth_code,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/platforms', action: 'callback', id: self.id, host: domain)
      }.to_query
      url.to_s
    end

  end
end
