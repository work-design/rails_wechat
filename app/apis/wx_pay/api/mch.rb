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

    def h5_order(description:, out_trade_no:, notify_url:, amount:, scene_info:)
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

    def order_query(out_trade_no)
      get "/v3/pay/transactions/out-trade-no/#{out_trade_no}", origin: BASE
    end

    def invoke_refund(out_refund_no:, amount:)
      post '/v3/refund/domestic/refunds', origin: BASE
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

    def certs
      get '/v3/certificates', origin: BASE
    end

    def profit_share(params = {})
      post '/v3/profitsharing/orders', params: params, origin: BASE
    end

    def profit_query(transaction_id)
      get "/v3/profitsharing/transactions/#{transaction_id}/amounts", origin: BASE
    end

    def common_payee_params
      {
        appid: @app_payee.appid,
        mchid: @payee.mch_id
      }
    end

  end
end
