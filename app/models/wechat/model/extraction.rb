module Wechat
  module Model::Extraction
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :matched, :string
      attribute :serial_number, :integer

      belongs_to :wechat_request
      belongs_to :extractor
    end

    def respond_text
      if serial_number.present?
        "#{extractor.valid_response}#{serial_number}"
      end
    end

  end
end
