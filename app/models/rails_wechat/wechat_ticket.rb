module RailsWechat::WechatTicket
  extend ActiveSupport::Concern

  included do
    attribute :signature, :string
    attribute :timestamp, :integer
    attribute :nonce, :string
    attribute :msg_signature, :string
    attribute :appid, :string
    attribute :ticket_data, :string
  end

end
