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
      url = BASE + path
      r = common_options
      r.merge! signature: WxPay::Sign::Rsa.generate(method, path, params, key: @payee.apiclient_key, **r)
      r = r.map(&->(k,v){ "#{k}=\"#{v}\"" }).join(',')
      opts = {
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'Wechatpay-Serial': @payee.platform_serial_no,
          Authorization: [AUTH, r].join(' ')
        }
      }
      if method != 'GET'
        opts.merge! body: params.to_json
      end

      r = HTTPX.with(debug: STDERR, debug_level: 2).request(method, url, **opts)
      r.json
    end

    def generate_js_pay_req(params)
      opts = {
        appId: @payee.appid,
        package: "prepay_id=#{params.delete(:prepayid)}",
        signType: 'RSA'
      }
      opts.merge! params
      opts[:timeStamp] ||= Time.current.to_i.to_s
      opts[:nonceStr] ||= SecureRandom.hex

      opts[:paySign] = WxPay::Sign.generate_sign(opts, key: @payee.apiclient_key)
      opts
    end

    def common_options
      {
        mchid: @payee.mch_id,
        serial_no: @payee.serial_no,
        nonce_str: SecureRandom.hex,
        timestamp: Time.current.to_i
      }
    end

  end
end
