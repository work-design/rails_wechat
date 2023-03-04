module WxPay::Api
  class Base
    AUTH = 'WECHATPAY2-SHA256-RSA2048'
    BASE = 'https://api.mch.weixin.qq.com'

    def initialize(payee:, appid: nil)
      @appid = appid
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

      with_common_headers('GET', path, headers: headers) do |signed_headers|
        response = @client.with_headers(signed_headers).with(with_options).get(path, params: params)
        debug ? response : response.json
      end
    end

    def post(path, origin: nil, params: {}, headers: {}, debug: nil, **payload)
      with_options = { origin: origin }
      with_options.merge! debug: Rails.logger.instance_values['logdev'].dev, debug_level: 2 if debug

      with_common_headers('POST', path, params: payload, headers: headers) do |signed_headers|
        response = @client.with_headers(signed_headers).with(with_options).post(path, params: params, json: payload)
        response.json
      end
    end

    def certs
      get '/v3/certificates', origin: BASE
    end

    def generate_js_pay_req(prepay_id:, time_stamp: Time.current.to_i.to_s, nonce_str: SecureRandom.hex)
      opts = {
        appId: @appid,
        timeStamp: time_stamp,
        nonceStr: nonce_str,
        package: "prepay_id=#{prepay_id}",
        signType: 'RSA'
      }
      str = [opts[:appId], opts[:timeStamp], opts[:nonceStr], opts[:package]].join("\n") + "\n"

      opts[:paySign] = Sign::Rsa.sign(str, @payee.apiclient_key)
      opts
    end

    def with_common_headers(method, path, params: {}, headers: {})
      r = {
        mchid: @payee.mch_id,
        serial_no: @payee.serial_no,
        nonce_str: SecureRandom.hex,
        timestamp: Time.current.to_i
      }

      r.merge! signature: Sign::Rsa.generate(method, path, params, key: @payee.apiclient_key, **r)
      r = r.map(&->(k,v){ "#{k}=\"#{v}\"" }).join(',')

      headers.merge!(
        'Wechatpay-Serial': @payee.platform_serial_no,
        Authorization: [AUTH, r].join(' ')
      )

      yield headers
    end

  end
end
