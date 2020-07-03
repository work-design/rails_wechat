# 客服消息
# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Service_Center_messages.html#7
class Wechat::Message::Custom < Wechat::Message::Base

  def transfer_customer_service(kf_account = nil)
    if kf_account
      update(MsgType: 'transfer_customer_service', TransInfo: { KfAccount: kf_account })
    else
      update(MsgType: 'transfer_customer_service')
    end
  end

  def to(openid)
    @message_hash.merge! touser: openid
  end

  def do_send
    api.message_custom_send self
  end

end
