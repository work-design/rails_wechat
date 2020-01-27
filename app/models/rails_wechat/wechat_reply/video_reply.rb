module RailsWechat::WechatReply::VideoReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'video'
    attribute :title, :string
    attribute :description, :string
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
