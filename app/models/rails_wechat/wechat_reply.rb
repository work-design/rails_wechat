# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Passive_user_reply_message.html
module RailsWechat::WechatReply
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :value, :string
    attribute :title, :string
    attribute :description, :string
    attribute :body, :json
    attribute :appid, :string, index: true

    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    belongs_to :messaging, polymorphic: true, optional: true

    has_one_attached :media
  end

  def invoke_effect(request_from = nil, **options)
    self.assign_attributes options
    self
  end

  def content
    {}
  end

  def to_wechat
    r = {
      MsgType: msg_type,
      CreateTime: Time.current.to_i
    }.merge! content
    r.merge!(FromUserName: wechat_app.user_name) if wechat_app
    r
  end

end
