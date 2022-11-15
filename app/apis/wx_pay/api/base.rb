module WxPay::Api
  class Base
    AUTH = 'WECHATPAY2-SHA256-RSA2048'

    include Mch

    def initialize(payee)
      @payee = payee
      @client = HTTPX.with(
        ssl: {
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        },
        headers: {
          'Accept' => 'application/json'
        }
      )
    end

    def get(path, origin: nil, params: {}, headers: {}, debug: nil)
      with_options = { origin: origin }
      with_options.merge! debug: STDERR, debug_level: 2 if debug

      @client.with_headers(headers).with(with_options).get(path, params: params)
    end

    def post(path, params = {})
      r = common_options
      r.merge! signature: WxPay::Sign::Rsa.generate('POST', path, params, key: @payee.apiclient_key, **r)
      r = r.map(&->(k,v){ "#{k}=\"#{v}\"" }).join(',')
      opts = {
        headers: {
          'Content-Type': 'application/json',
          'Wechatpay-Serial': @payee.platform_serial_no,
          Authorization: [AUTH, r].join(' ')
        }
      }

      opts.merge! body: params.to_json

      r = @client.with_headers(headers).with(with_options).post(path, params: params, json: payload)
      r.json
    end

    def with_signature

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

    def with_common_options
      {
        mchid: @payee.mch_id,
        serial_no: @payee.serial_no,
        nonce_str: SecureRandom.hex,
        timestamp: Time.current.to_i
      }
    end

  end
end
