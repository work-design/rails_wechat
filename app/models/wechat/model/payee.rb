module Wechat
  module Model::Payee
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :mch_id, :string, comment: '支付专用、商户号'
      attribute :key, :string, comment: '支付专用'
      attribute :key_v3, :string, comment: '支付通知解密'
      attribute :serial_no, :string
      attribute :apiclient_cert, :string
      attribute :apiclient_key, :string
      attribute :platform_effective_at, :datetime
      attribute :platform_expire_at, :datetime
      attribute :platform_serial_no, :string
      attribute :encrypt_certificate, :json

      encrypts :key, :key_v3, :apiclient_cert, :apiclient_key

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :payee_apps, primary_key: :mch_id, foreign_key: :mch_id, dependent: :destroy
      has_many :payee_domains, primary_key: :mch_id, foreign_key: :mch_id, dependent: :destroy

      validates :mch_id, presence: true, uniqueness: { scope: [:organ_id] }
    end

    def rsa_encrypt(data)
      r = WxPay::Cipher.decrypt(encrypt_certificate['ciphertext'], key: key_v3, iv: encrypt_certificate['nonce'], auth_data: encrypt_certificate['associated_data'])
      cipher = OpenSSL::X509::Certificate.new(r).public_key
      result = cipher.encrypt data, rsa_padding_mode: 'oaep'
      Base64.encode64(result)
    end

    def api
      return @api if defined? @api
      @api = WxPay::MchApi.new(payee: self)
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
