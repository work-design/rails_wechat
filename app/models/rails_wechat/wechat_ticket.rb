module RailsWechat::WechatTicket
  extend ActiveSupport::Concern

  included do
    attribute :signature, :string
    attribute :timestamp, :integer
    attribute :nonce, :string
    attribute :msg_signature, :string
    attribute :appid, :string
    attribute :ticket_data, :string

    belongs_to :wechat_platform, foreign_key: :appid, primary_key: :appid
  end

  def parse_data
    r = Wechat::Cipher.decrypt(Base64.decode64(ticket_data), wechat_platform.encoding_aes_key)
    content, _ = Wechat::Cipher.unpack(r)

    Hash.from_xml(content).fetch('xml', {})
  end

end
