module WxPay::Api
  class Partner < Base
    BASE = 'https://api.mch.weixin.qq.com'

    def initialize(payee:, appid: nil)
      super
      @partner = payee.partner
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
      get "/v3/pay/partner/transactions/out-trade-no/#{out_trade_no}", params: { sp_mchid: , sub_mchid:  }, origin: BASE
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

    def profit_share(params = {})
      post '/v3/profitsharing/orders', params: params, origin: BASE
    end

    def profit_query(transaction_id)
      get "/v3/profitsharing/transactions/#{transaction_id}/amounts", origin: BASE
    end

    def common_payee_params
      {
        sp_appid: @partner.appid,
        sp_mchid: @partner.mch_id,
        sub_appid: @appid,
        sub_mchid: @payee.mch_id
      }
    end

    def with_common_headers(method, path, params: {}, headers: {})
      r = {
        mchid: @partner.mch_id,
        serial_no: @partner.serial_no,
        nonce_str: SecureRandom.hex,
        timestamp: Time.current.to_i
      }

      r.merge! signature: WxPay::Sign::Rsa.generate(method, path, params, key: @partner.apiclient_key, **r)
      r = r.map(&->(k,v){ "#{k}=\"#{v}\"" }).join(',')

      headers.merge!(
        'Wechatpay-Serial': @payee.platform_serial_no,
        Authorization: [AUTH, r].join(' ')
      )

      yield headers
    end

  end
end