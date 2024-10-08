# https://pay.weixin.qq.com/wiki/doc/apiv3/apis/chapter8_1_8.shtml
module Wechat
  module Model::Receiver
    extend ActiveSupport::Concern

    included do
      attribute :account, :string
      attribute :name, :string
      attribute :custom_relation, :string
      attribute :res, :json

      enum :receiver_type, {
        merchant_id: 'merchant_id',  # 户号（mch_id或者sub_mch_id）
        personal_openid: 'personal_openid' # 个人openid
      }

      enum :relation_type, {
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
      }, prefix: true

      belongs_to :app_payee

      after_save_commit :sync_to_wxpay, if: -> { (saved_changes.keys & ['account', 'name']).present? }
    end

    def order_params(amount: 0.01, description: '冻结')
      {
        type: receiver_type.upcase,
        account: account,
        name: payee.rsa_encrypt(name),
        amount: (amount * 100).to_i,
        description: description
      }
    end

    def add_params
      {
        appid: payee.appid,
        type: receiver_type.upcase,
        account: account,
        name: payee.rsa_encrypt(name),
        relation_type: relation_type.upcase,
        custom_relation: custom_relation
      }
    end

    def sync_to_wxpay
      r = payee.api.add_receiver(add_params)
      self.res = r
      self.save
    end

    def remove_from_wxpay
      params = {
        appid: payee.appid,
        type: receiver_type.upcase,
        account: account
      }
      r = payee.api.delete_receiver(params)
      self.res = r
      self.save
    end

  end
end
