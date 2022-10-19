module WxPay::Api
  class Base
    AUTH = 'WECHATPAY2-SHA256-RSA2048'
    BASE = 'https://api.mch.weixin.qq.com'.freeze
    include V3

    def initialize(payee)
      @payee = payee
    end

    def execute(method, path, params, options = {})
      method.upcase!
      path = WxPay::Utils.replace(path, params)
      path = WxPay::Utils.query(path, params) if method == 'GET'

      options[:nonce_str] ||= SecureRandom.uuid.tr('-', '')
      options[:timestamp] ||= Time.current.to_i
      options[:signature] = WxPay::Sign::Rsa.generate(method, path, params, key: @payee.apiclient_key, **options)

      url = BASE + path
      opts = {
        headers: common_headers(options)
      }
      if method != 'GET'
        opts.merge! body: params.to_json
      end

      r = HTTPX.with(debug: STDERR, debug_level: 2).request(method, url, **opts)
      r.json
    end

    def generate_js_pay_req(params, options = {})
      opts = {
        appId: @payee.appid,
        package: "prepay_id=#{params.delete(:prepayid)}",
        signType: 'RSA'
      }
      opts.merge! params
      opts[:timeStamp] ||= Time.current.to_i.to_s
      opts[:nonceStr] ||= SecureRandom.uuid.tr('-', '')
      opts[:paySign] = WxPay::Sign.generate_sign(opts, options)
      opts
    end

    def common_headers(options)
      r = {
        mchid: @payee.mch_id,
        serial_no: @payee.serial_no,
        nonce_str: options[:nonce_str],
        timestamp: options[:timestamp],
        signature: options[:signature]
      }.map(&->(k,v){ "#{k}=\"#{v}\"" }).join(',')
      {
        Authorization: [AUTH, r].join(' '),
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    end

  end
end
