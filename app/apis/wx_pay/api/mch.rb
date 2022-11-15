module WxPay::Api
  module Mch
    BASE = 'https://api.mch.weixin.qq.com'

    def invoke_unifiedorder
      post '/v3/pay/transactions/jsapi',
        required: [:appid, :mchid, :description, :out_trade_no, :notify_url, :amount, :payer],
        optional: [:time_expire, :attach, :goods_tag, :detail, :scene_info]
    end

    def h5_order
      post '/v3/pay/transactions/h5',
        required: [:appid, :mchid, :description, :out_trade_no, :notify_url, :amount, :scene_info],
        optional: [:time_expire, :attach, :goods_tag, :detail, :settle_info]
    end

    def native_order
      post '/v3/pay/transactions/native',
        required: [:appid, :mchid, :description, :out_trade_no, :notify_url, :amount],
        optional: [:time_expire, :attach, :goods_tag, :detail, :scene_info]
    end

    def order_query(out_trade_no)
      get "/v3/pay/transactions/out-trade-no/#{out_trade_no}"
    end

    def invoke_refund(out_refund_no:, amount:)
      post '/v3/refund/domestic/refunds'
    end

    def refund_query(out_refund_no)
      get "/v3/refund/domestic/refunds/#{out_refund_no}"
    end

    def add_receiver(receiver)
      post '/v3/profitsharing/receivers/add', receiver: receiver
    end

    def delete_receiver
      post '/v3/profitsharing/receivers/delete'
    end

    def certs
      get '/v3/certificates'
    end

    def profit_share(params = {})
      post '/v3/profitsharing/orders', params
    end

    def profit_query(transaction_id)
      get "/v3/profitsharing/transactions/#{transaction_id}/amounts"
    end

  end
end
