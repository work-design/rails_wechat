# https://pay.weixin.qq.com/wiki/doc/apiv3/apis/chapter8_1_8.shtml
module Wechat
  module Model::Receiver
    extend ActiveSupport::Concern

    included do
      attribute :account, :string
      attribute :name, :string
      attribute :custom_relation, :string

      enum receiver_type: {
        merchant_id: 'merchant_id',  # 户号（mch_id或者sub_mch_id）
        personal_openid: 'personal_openid' # 个人openid
      }

      enum relation_type: {
        store: 'store', # 门店
        staff: 'staff', # 员工
        store_owner: 'store_owner', # 店主
        partner: 'partner', # 合作伙伴
        headquarter: 'headquarter', # 总部
        brand: 'brand',  #品牌方
        distributor: 'distributor', #分销商
        user: 'user', #用户
        supplier: 'supplier', #供应商
        custom: 'custom' #自定义
      }, _prefix: true

      belongs_to :payee
    end

    def params
      {
        appid: payee.appid,
        type: receiver_type.upcase,
        account: account,
        name: WxPay::Sign::Rsa.sign(name, payee.apiclient_key),
        relation_type: relation_type.upcase,
        custom_relation: custom_relation
      }
    end

    def sync_to_wxpay
      payee.api.add_receiver(params)
    end

  end
end
