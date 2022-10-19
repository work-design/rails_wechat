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
      attribute :platform_effective_at, :datetime
      attribute :platform_expire_at, :datetime
      attribute :platform_serial_no, :string
      attribute :encrypt_certificate, :json

      encrypts :key, :key_v3, :apiclient_cert, :apiclient_key

      belongs_to :organ, class_name: 'Org::Organ'

      belongs_to :app, foreign_key: :appid, primary_key: :appid, counter_cache: true
      has_many :receivers
    end

    def api
      return @api if defined? @api
      @api = WxPay::Api::Base.new(self)
    end

    def platform_key
      WxPay::Cipher.decrypt(encrypt_certificate['ciphertext'], key: key_v3, iv: encrypt_certificate['nonce'], auth_data: encrypt_certificate['associated_data'])
    end

    def sync_cert!
      certs = api.certs['data']
      result = certs.select(&->(i){ i['effective_time'].to_time < Time.current }).min_by do |cert|
        cert['expire_time'].to_time
      end
      self.platform_effective_at = result['effective_time']
      self.platform_expire_at = result['expire_time']
      self.platform_serial_no = result['serial_no']
      self.encrypt_certificate = result['encrypt_certificate']
      self.save!
    end

  end
end
