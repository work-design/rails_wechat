module RailsWechat::WechatReply::VideoReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'video'
  end

  def content
    {
      Video: {
        MediaId: value,
        Title: title,
        Description: description
      }
    }
  end


end
