module WxPay
  module OldApi


    INVOKE_CLOSEORDER_REQUIRED_FIELDS = [:out_trade_no]
    def self.invoke_closeorder(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', '')
               }.merge(params)

      check_required_options(params, INVOKE_CLOSEORDER_REQUIRED_FIELDS)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/closeorder", make_payload(params), options)))

      yield r if block_given?

      r
    end

    GENERATE_APP_PAY_REQ_REQUIRED_FIELDS = [:prepayid, :noncestr]
    def self.generate_app_pay_req(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 partnerid: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 package: 'Sign=WXPay',
                 timestamp: Time.now.to_i.to_s
               }.merge(params)

      check_required_options(params, GENERATE_APP_PAY_REQ_REQUIRED_FIELDS)

      params[:sign] = WxPay::Sign.generate(params)

      params
    end

    INVOKE_TRANSFER_REQUIRED_FIELDS = [:partner_trade_no, :openid, :check_name, :amount, :desc, :spbill_create_ip]
    def self.invoke_transfer(params, options = {})
      params = {
                 mch_appid: options.delete(:appid) || WxPay.appid,
                 mchid: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, INVOKE_TRANSFER_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaymkttransfers/promotion/transfers", make_payload(params), options)))

      yield r if block_given?

      r
    end

    GETTRANSFERINFO_FIELDS = [:partner_trade_no]
    def self.gettransferinfo(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, GETTRANSFERINFO_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaymkttransfers/gettransferinfo", make_payload(params), options)))

      yield r if block_given?

      r
    end

    # 获取加密银行卡号和收款方用户名的RSA公钥
    def self.risk_get_public_key(options = {})
      params = {
        mch_id: options.delete(:mch_id) || WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', ''),
        key: options.delete(:key) || WxPay.key,
        sign_type: 'MD5'
      }

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                  gateway_url: FRAUD_GATEWAY_URL
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/risk/getpublickey", make_payload(params), options)))

      yield r if block_given?

      r
    end

    PAY_BANK_FIELDS = [:enc_bank_no, :enc_true_name, :bank_code, :amount, :desc]
    def self.pay_bank(params, options = {})
      params = {
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key,
               }.merge(params)

      check_required_options(params, PAY_BANK_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaysptrans/pay_bank", make_payload(params), options)))

      yield r if block_given?

      r
    end

    QUERY_BANK_FIELDS = [:partner_trade_no]
    def self.query_bank(params, options = {})
      params = {
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key,
               }.merge(params)

      check_required_options(params, QUERY_BANK_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaysptrans/query_bank", make_payload(params), options)))

      yield r if block_given?

      r
    end

    INVOKE_REVERSE_REQUIRED_FIELDS = [:out_trade_no]
    def self.invoke_reverse(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', '')
               }.merge(params)

      check_required_options(params, INVOKE_REVERSE_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/secapi/pay/reverse", make_payload(params), options)))

      yield r if block_given?

      r
    end

    INVOKE_MICROPAY_REQUIRED_FIELDS = [:body, :out_trade_no, :total_fee, :spbill_create_ip, :auth_code]
    def self.invoke_micropay(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', '')
               }.merge(params)

      check_required_options(params, INVOKE_MICROPAY_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/micropay", make_payload(params), options)))

      yield r if block_given?

      r
    end

    DOWNLOAD_BILL_REQUIRED_FIELDS = [:bill_date, :bill_type]
    def self.download_bill(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
               }.merge(params)

      check_required_options(params, DOWNLOAD_BILL_REQUIRED_FIELDS)

      r = invoke_remote("/pay/downloadbill", make_payload(params), options)

      yield r if block_given?

      r
    end

    DOWNLOAD_FUND_FLOW_REQUIRED_FIELDS = [:bill_date, :account_type]
    def self.download_fund_flow(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, DOWNLOAD_FUND_FLOW_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = invoke_remote("/pay/downloadfundflow", make_payload(params, WxPay::Sign::SIGN_TYPE_HMAC_SHA256), options)

      yield r if block_given?

      r
    end

    def self.sendgroupredpack(params, options={})
      params = {
                 wxappid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', '')
               }.merge(params)

      #check_required_options(params, INVOKE_MICROPAY_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaymkttransfers/sendgroupredpack", make_payload(params), options)))

      yield r if block_given?

      r
    end

    def self.sendredpack(params, options={})
      params = {
                 wxappid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 key: options.delete(:key) || WxPay.key,
                 nonce_str: SecureRandom.uuid.tr('-', '')
               }.merge(params)

      #check_required_options(params, INVOKE_MICROPAY_REQUIRED_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaymkttransfers/sendredpack", make_payload(params), options)))

      yield r if block_given?

      r
    end

    # 用于商户对已发放的红包进行查询红包的具体信息，可支持普通红包和裂变包。
    GETHBINFO_FIELDS = [:mch_billno, :bill_type]
    def self.gethbinfo(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, GETHBINFO_FIELDS)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/mmpaymkttransfers/gethbinfo", make_payload(params), options)))

      yield r if block_given?

      r
    end

    PROFITSHARINGADDRECEIVER = [:nonce_str, :receiver]

    # 添加分账接收方
    def self.profitsharingaddreceiver(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, PROFITSHARINGADDRECEIVER)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/profitsharingaddreceiver", make_payload(params, WxPay::Sign::SIGN_TYPE_HMAC_SHA256), options)))

      yield r if block_given?

      r
    end

    PROFITSHARINGREMOVERECEIVER = [:nonce_str, :receiver]
    # 删除分账接收方
    def self.profitsharingremovereceiver(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, PROFITSHARINGADDRECEIVER)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/profitsharingremovereceiver", make_payload(params, WxPay::Sign::SIGN_TYPE_HMAC_SHA256), options)))

      yield r if block_given?

      r
    end

    # 单次分账

    PROFITSHARING = [:nonce_str, :receivers, :transaction_id, :out_order_no]

    def self.profitsharing(params, options = {})
      params = {
                 appid: options.delete(:appid) || WxPay.appid,
                 mch_id: options.delete(:mch_id) || WxPay.mch_id,
                 nonce_str: SecureRandom.uuid.tr('-', ''),
                 key: options.delete(:key) || WxPay.key
               }.merge(params)

      check_required_options(params, PROFITSHARING)

      options = {
                  ssl_client_cert: options.delete(:apiclient_cert) || WxPay.apiclient_cert,
                  ssl_client_key: options.delete(:apiclient_key) || WxPay.apiclient_key,
                  verify_ssl: OpenSSL::SSL::VERIFY_NONE
                }.merge(options)

      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/secapi/pay/profitsharing", make_payload(params, WxPay::Sign::SIGN_TYPE_HMAC_SHA256), options)))

      yield r if block_given?

      r
    end

  end
end
