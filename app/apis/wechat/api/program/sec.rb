module Wechat::Api
  module Program::Sec
    BASE = 'https://api.weixin.qq.com/wxa/sec/'

    def upload_shipping_info(transaction_id:, shipping_list:, openid:, logistics_type: 4, delivery_mode: 1, upload_time: Time.current, **options)
      post(
        'order/upload_combined_shipping_info',
        order_key: {
          order_number_type: 2,
          transaction_id: transaction_id
        },
        logistics_type: logistics_type,
        delivery_mode: delivery_mode,
        shipping_list: shipping_list,
        upload_time: upload_time,
        payer: { openid: openid },
        **options)
    end

    def get_order(transaction_id)
      post 'order/get_order', transaction_id: transaction_id
    end

  end
end

