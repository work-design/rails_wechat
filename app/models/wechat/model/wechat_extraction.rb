module Wechat
  module RailsWechat::WechatExtraction
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :matched, :string
      attribute :serial_number, :integer

      belongs_to :wechat_request
      belongs_to :wechat_extractor
    end

    def respond_text
      if serial_number.present?
        "#{wechat_extractor.valid_response}#{serial_number}"
      end
    end

  end
end
