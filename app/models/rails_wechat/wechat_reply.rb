# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Passive_user_reply_message.html
module RailsWechat::WechatReply
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :value, :string
    attribute :title, :string
    attribute :description, :string
    attribute :body, :json

    belongs_to :wechat_app
    belongs_to :wechat_user, optional: true
    belongs_to :messaging, polymorphic: true, optional: true

    has_one_attached :media
  end

  def invoke_effect(request_from)
    value
  end

  def content
    {}
  end

  def to_wechat
    { MsgType: msg_type }.merge! content
  end

end
