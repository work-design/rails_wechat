module RailsWechat::WechatReply::VoiceReply

  def voice(media_id)
    update(MsgType: 'voice', Voice: { MediaId: media_id })
  end

end
