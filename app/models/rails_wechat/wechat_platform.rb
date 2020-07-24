module RailsWechat::WechatPlatform
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
  end

  def api
    retutn @api if defined? @api
    @api = Wechat::Api::Platform.new(self)
  end

  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

end
