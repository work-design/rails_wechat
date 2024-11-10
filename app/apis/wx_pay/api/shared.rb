module WxPay::Api
  module Shared

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
          .post('pay/micropay', body: opts.to_xml(root: 'xml', skip_types: true, skip_instruct: true, dasherize: false))
      Hash.from_xml(r.to_s)['xml']
    end

  end
end
