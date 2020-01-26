module RailsWechat::WechatReply::VoiceReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'voice'
  end

  def voice(media_id)
    update(MsgType: 'voice', Voice: { MediaId: media_id })
  end

end
