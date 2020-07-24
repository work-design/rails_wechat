module RailsWechat::WechatTicket
  extend ActiveSupport::Concern

  included do
    attribute :signature, :string
    attribute :timestamp, :integer
    attribute :nonce, :string
    attribute :msg_signature, :string
    attribute :appid, :string
    attribute :ticket_data, :string

    belongs_to :wechat_platform, foreign_key: :appid, primary_key: :appid, optional: true

    after_create_commit :parsed_data, if: -> { wechat_platform.present? }
  end

  def parsed_data
    r = Wechat::Cipher.decrypt(Base64.decode64(ticket_data), wechat_platform.encoding_aes_key)
    content, _ = Wechat::Cipher.unpack(r)

    data = Hash.from_xml(content).fetch('xml', {})
    wechat_platform.update(verify_ticket: data['ComponentVerifyTicket'])
    data
  end

end
