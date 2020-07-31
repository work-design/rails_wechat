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
    attribute :open_id, :string, index: true

    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
    belongs_to :messaging, polymorphic: true, optional: true

    has_one_attached :media
  end

  def invoke_effect(request_from = nil)
    value
  end

  def content
    {}
  end

  def to_wechat
    r = {
      MsgType: msg_type,
      CreateTime: Time.current.to_i
    }.merge! content
    r.merge!(ToUserName: wechat_user.uid) if wechat_user
    r.merge!(FromUserName: wechat_app.user_name) if wechat_app
    r
  end

  def to_xml
    to_wechat.to_xml(
      root: 'xml',
      children: 'item',
      skip_instruct: true,
      skip_types: true
    )
  end

end
