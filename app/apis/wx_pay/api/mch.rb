module WxPay::Api
  class Mch < Base
    BASE = 'https://api.mch.weixin.qq.com'

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

    def add_receiver(receiver)
      post '/v3/profitsharing/receivers/add', receiver: receiver, origin: BASE
    end

    def delete_receiver
      post '/v3/profitsharing/receivers/delete', origin: BASE
    end

    def profit_share(params = {})
      post '/v3/profitsharing/orders', params: params, origin: BASE
    end

    def profit_query(transaction_id)
      get "/v3/profitsharing/transactions/#{transaction_id}/amounts", origin: BASE
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

      opts[:paySign] = WxPay::Sign::Rsa.sign(str, @payee.apiclient_key)
      opts
    end

    def pay_micropay(out_trade_no:, auth_code:, body:, total_fee:, spbill_create_ip:)
      post(
        'pay/micropay',
        body: body,
        out_trade_no: out_trade_no,
        total_fee: total_fee,
        spbill_create_ip: spbill_create_ip,
        auth_code: auth_code,
        sign: xx,
        **v2_common_payee_params
      )
    end

    def common_payee_params
      {
        appid: @appid,
        mchid: @payee.mch_id
      }
    end

    def v2_common_payee_params
      {
        appid: @appid,
        mch_id: @payee.mch_id
      }
    end

    def v2_sign_params
      {
        nonce_str: SecureRandom.hex,
        sign_type: 'HMAC-SHA256'
      }
    end

  end
end
