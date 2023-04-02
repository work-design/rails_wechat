module WxPay::Api
  class Partner < Base
    BASE = 'https://api.mch.weixin.qq.com'

    def initialize(partner:, payee: nil, appid: nil)
      super(appid: appid)
      @payee = payee
      @mch = partner
    end

    def jsapi_order(description:, out_trade_no:, notify_url:, amount:, payer:, **options)
      post(
        '/v3/pay/partner/transactions/jsapi',
        description: description,
        out_trade_no: out_trade_no,
        notify_url: notify_url,
        amount: amount,
        payer: { sub_openid: payer[:openid] },
        origin: BASE,
        **common_payee_params,
        **options
      )
    end

    def h5_order(description:, out_trade_no:, notify_url:, amount:, scene_info:)
      post(
        '/v3/pay/partner/transactions/h5',
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
        '/v3/pay/partner/transactions/native',
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
      get "/v3/pay/partner/transactions/out-trade-no/#{out_trade_no}", params: { sp_mchid: @mch.mch_id, sub_mchid: @payee.mch_id }, origin: BASE
    end

    def invoke_refund(out_refund_no:, transaction_id:, amount:, **options)
      post(
        '/v3/refund/domestic/refunds',
        transaction_id: transaction_id,
        out_refund_no: out_refund_no,
        amount: amount,
        origin: BASE,
        sub_mchid: @payee.mch_id,
        **options
      )
    end

    def refund_query(out_refund_no)
      get "/v3/refund/domestic/refunds/#{out_refund_no}", params: { sub_mchid: @payee.mch_id }, origin: BASE
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

    def common_payee_params
      {
        sp_appid: @mch.appid,
        sp_mchid: @mch.mch_id,
        sub_appid: @appid,
        sub_mchid: @payee.mch_id
      }
    end

  end
end
