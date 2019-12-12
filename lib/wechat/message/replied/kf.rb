class Wechat::Message::Replied::RepliedKf < Wechat::Message::Replied
  
  def transfer_customer_service(kf_account = nil)
    if kf_account
      @message_hash.merge!(MsgType: 'transfer_customer_service', TransInfo: { KfAccount: kf_account })
    else
      @message_hash.merge!(MsgType: 'transfer_customer_service')
    end
  end
    
end
