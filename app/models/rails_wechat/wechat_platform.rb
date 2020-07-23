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
    @api = Wechat::Api::Public.new(self)
  end

end
