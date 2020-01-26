module RailsWechat::WechatReply::ImageReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'image'
  end


  def content
    update(MsgType: 'image', Image: { MediaId: value })
  end

end
