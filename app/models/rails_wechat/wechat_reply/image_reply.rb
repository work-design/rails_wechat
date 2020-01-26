module RailsWechat::WechatReply::ImageReply


  def content
    update(MsgType: 'image', Image: { MediaId: value })
  end

end
