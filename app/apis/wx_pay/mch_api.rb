module WxPay
  class MchApi < BaseApi
    BASE = 'https://api.mch.weixin.qq.com'

    def initialize(payee:, appid: nil)
      super(appid: appid)
      @mch = payee
    end

    def jsapi_order(description:, out_trade_no:, notify_url:, amount:, payer:, **options)
      post(
        '/v3/pay/transactions/jsapi',
        description: description,
        out_trade_no: out_trade_no,
        notify_url: notify_url,
        amount: amount,
        payer: payer,
        origin: BASE,
        **common_payee_params,
        **options
      )
    end

    def h5_order(description:, out_trade_no:, notify_url:, amount:, scene_info:, **options)
      post(
        '/v3/pay/transactions/h5',
        description: description,
        out_trade_no: out_trade_no,
        notify_url: notify_url,
        amount: amount,
        scene_info: scene_info,
        origin: BASE,
        **common_payee_params,
        **options
      )
    end

    def native_order(description:, out_trade_no:, notify_url:, amount:, **options)
      post(
        '/v3/pay/transactions/native',
        description: description,
        out_trade_no: out_trade_no,
        notify_url: notify_url,
        amount: amount,
        origin: BASE,
        **common_payee_params,
        **options
      )
    end

    def invoke_refund(out_refund_no:, transaction_id:, amount:, **options)
      post(
        '/v3/refund/domestic/refunds',
        transaction_id: transaction_id,
        out_refund_no: out_refund_no,
        amount: amount,
        origin: BASE,
        **options
      )
    end

    def order_query(out_trade_no)
      get "/v3/pay/transactions/out-trade-no/#{out_trade_no}", origin: BASE
    end

    def refund_query(out_refund_no)
      get "/v3/refund/domestic/refunds/#{out_refund_no}", origin: BASE
    end

    def pay_micropay(out_trade_no:, auth_code:, body:, total_fee:, spbill_create_ip:)
      opts = {
        nonce_str: SecureRandom.hex,
        sign_type: 'HMAC-SHA256',
        body: body,
        out_trade_no: out_trade_no,
        total_fee: total_fee,
        spbill_create_ip: spbill_create_ip,
        auth_code: auth_code,
        **v2_common_payee_params
      }
      opts.merge! sign: WxPay::Sign::Hmac.generate(opts, key: @mch.key)

      r = @client.with_options(origin: BASE, debug: Rails.logger.broadcasts[0].instance_values['logdev'].dev, debug_level: 2)
          .post('/pay/micropay', body: opts.to_xml(root: 'xml', skip_types: true, skip_instruct: true, dasherize: false))
      Hash.from_xml(r.to_s)['xml']
    end

    def common_payee_params
      {
        appid: @appid,
        mchid: @mch.mch_id
      }
    end

    def v2_common_payee_params
      {
        appid: @appid,
        mch_id: @mch.mch_id
      }
    end

    def v2_sign_params
      {
        sign_type: 'HMAC-SHA256'
      }
    end

  end
end
