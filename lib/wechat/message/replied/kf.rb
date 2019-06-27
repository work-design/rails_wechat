module Wechat::Message
  class Replied::RepliedKf < Replied
  
    def transfer_customer_service(kf_account = nil)
      if kf_account
        update(MsgType: 'transfer_customer_service', TransInfo: { KfAccount: kf_account })
      else
        update(MsgType: 'transfer_customer_service')
      end
    end
    
  end
end
