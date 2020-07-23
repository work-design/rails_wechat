module RailsWechat::WechatTicket
  extend ActiveSupport::Concern

  included do
    attribute :signature, :string
    attribute :timestamp, :integer
    attribute :nonce, :string
    attribute :msg_signature, :string
    attribute :ticket_data, :string
  end

  def test_data
    {
      "signature"=>"100b93a2d3cd720e7cbfc8833b0ca56b36368deb",
      "timestamp"=>"1595504773",
      "nonce"=>"122075998",
      "encrypt_type"=>"aes",
      "msg_signature"=>"b31a47023fdcc6b58fa0aeb061a5c830249fda07"
    }
  end

end
