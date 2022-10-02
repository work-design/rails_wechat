module Wechat
  module Model::Payee
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :mch_id, :string, comment: '支付专用、商户号'
      attribute :key, :string, comment: '支付专用'
      attribute :key_v3, :string, comment: '支付通知解密'
      attribute :serial_no, :string
      attribute :apiclient_cert, :string
      attribute :apiclient_key, :string
      attribute :domain, :string

      encrypts :key, :key_v3, :apiclient_cert, :apiclient_key

      belongs_to :organ, class_name: 'Org::Organ'

      belongs_to :app, foreign_key: :appid, primary_key: :appid
    end

  end
end
