module Wechat
  module Model::Account
    extend ActiveSupport::Concern

    include Model::EffectiveModule
    included do
      has_one :wechat_response, as: :effective
    end

    def invoke_effect(wechat_user)
      old_account = wechat_user.account
      if old_account == self
        "您的微信账号已经绑定到账号 #{identity} 了"
      elsif old_account
        wechat_user.update(account_id: self.id)
        old_account.access_tokens.delete_all  # 更改绑定关系后，old account 登陆失效
        "您的微信账号已更换绑定账号, 之前绑定的账号是#{old_account.identity}, 已经绑定到#{identity}"
      else
        wechat_user.update(account_id: self.id)
        "您的微信账号绑定至账号 #{identity} 成功"
      end
    end

  end
end
