module RailsWechat::WechatPlatform
  URL = 'https://mp.weixin.qq.com/dashboard/cgi-bin/componentloginpage'
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

    has_many :wechat_agencies
    has_many :wechat_auths
  end

  def api
    return @api if defined? @api
    @api = Wechat::Api::Platform.new(self)
  end

  def save_pre_auth_code(token_hash)
    unless token_hash.is_a?(Hash) && token_hash['pre_auth_code']
      raise Wechat::InvalidCredentialError, token_hash['errmsg']
    end

    self.pre_auth_code = token_hash['pre_auth_code']
    self.pre_auth_code_expires_at = Time.current + token_hash['expires_in'].to_i
    self.save
  end

  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

  def pre_auth_code_valid?
    return false unless pre_auth_code_expires_at.acts_like?(:time)
    pre_auth_code_expires_at > 3.minutes.since
  end

  def auth_url
    {
      component_appid: appid,
      pre_auth_code: pre_auth_code,
      redirect_uri: xx
    }
  end

end
