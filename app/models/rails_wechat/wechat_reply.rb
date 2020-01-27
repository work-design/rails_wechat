# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Passive_user_reply_message.html
module RailsWechat::WechatReply
  extend ActiveSupport::Concern
  included do
    attribute :type, :string
    attribute :value, :string
    attribute :body, :json

    belongs_to :wechat_app
    belongs_to :wechat_user
    belongs_to :messaging, polymorphic: true, optional: true
  end

  def invoke_effect(request_from)

  end

  def content
    {}
  end

  def to_wechat
    { MsgType: msg_type }.merge! content
  end

end
