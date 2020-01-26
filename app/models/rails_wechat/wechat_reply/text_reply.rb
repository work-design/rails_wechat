module RailsWechat::WechatReply::TextReply

  # 公众号消息类型
  # see: https://mp.weixin.qq.com/wiki?id=mp1421140543
  def content
    update(MsgType: 'text', Content: body)
  end

end
