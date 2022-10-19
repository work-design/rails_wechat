require 'httpx'
require 'json'
require 'cgi'
require 'securerandom'
require 'active_support/core_ext/hash/conversions'

module WxPay
  module Service
    extend self
    GATEWAY_URL = 'https://api.mch.weixin.qq.com'.freeze
    SANDBOX_GATEWAY_URL = 'https://api.mch.weixin.qq.com/sandboxnew'.freeze
    FRAUD_GATEWAY_URL = 'https://fraud.mch.weixin.qq.com'.freeze

    def generate_authorize_url(redirect_uri, state = nil)
      state ||= SecureRandom.hex 16
      "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{WxPay.appid}&redirect_uri=#{CGI::escape redirect_uri}&response_type=code&scope=snsapi_base&state=#{state}"
    end

    def authenticate(authorization_code, options = {})
      options = WxPay.extra_rest_client_options.merge(options)
      payload = {
        appid: options.delete(:appid) || WxPay.appid,
        secret: options.delete(:appsecret) || WxPay.appsecret,
        code: authorization_code,
        grant_type: 'authorization_code'
      }
      url = "https://api.weixin.qq.com/sns/oauth2/access_token"

      ::JSON.parse(RestClient::Request.execute(
        {
          method: :get,
          headers: {params: payload},
          url: url
        }.merge(options)
      ), quirks_mode: true)
    end

    def get_sandbox_signkey(mch_id = WxPay.mch_id, options = {})
      params = {
        mch_id: mch_id,
        key: options.delete(:key) || WxPay.key,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }
      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/getsignkey", xmlify_payload(params))))
      yield r if block_given?
      r
    end

    def authenticate_from_weapp(js_code, options = {})
      options = WxPay.extra_rest_client_options.merge(options)
      payload = {
        appid: options.delete(:appid) || WxPay.appid,
        secret: options.delete(:appsecret) || WxPay.appsecret,
        js_code: js_code,
        grant_type: 'authorization_code'
      }
      url = "https://api.weixin.qq.com/sns/jscode2session"

      ::JSON.parse(RestClient::Request.execute(
        {
          method: :get,
          headers: {params: payload},
          url: url
        }.merge(options)
      ), quirks_mode: true)
    end

    def get_gateway_url
      return SANDBOX_GATEWAY_URL if WxPay.sandbox_mode?
      GATEWAY_URL
    end

    def check_required_options(options, names)
      return unless WxPay.debug_mode?
      names.each do |name|
        warn("WxPay Warn: missing required option: #{name}") unless options.has_key?(name)
      end
    end

    def xmlify_payload(params, sign_type = WxPay::Sign::SIGN_TYPE_MD5)
      sign = WxPay::Sign.generate(params, sign_type)
      "<xml>#{params.except(:key).sort.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{sign}</sign></xml>"
    end

    def make_payload(params, sign_type = WxPay::Sign::SIGN_TYPE_MD5)
      if WxPay.sandbox_mode? && !WxPay.manual_get_sandbox_key?
        r = get_sandbox_signkey
        if r['return_code'] == WxPay::Result::SUCCESS_FLAG
          params = params.merge(
            mch_id: r['mch_id'] || WxPay.mch_id,
            key: r['sandbox_signkey']
          )
        else
          warn("WxPay Warn: fetch sandbox sign key failed #{r['return_msg']}")
        end
      end

      xmlify_payload(params, sign_type)
    end

    def invoke_remote(url, payload, options = {})
      options = WxPay.extra_rest_client_options.merge(options)
      gateway_url = options.delete(:gateway_url) || get_gateway_url
      url = "#{gateway_url}#{url}"

      HTTPX.post(
        url,
        {
          payload: payload,
          headers: { content_type: 'application/xml' }
        }.merge(options)
      )
    end

  end
end
