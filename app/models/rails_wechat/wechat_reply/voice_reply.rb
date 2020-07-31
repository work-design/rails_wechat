module RailsWechat::WechatReply::VoiceReply
  extend ActiveSupport::Concern

  included do
    attribute :msg_type, :string, default: 'voice'
  end

  def content
    {
      Voice: { MediaId: value }
    }
  end

end
