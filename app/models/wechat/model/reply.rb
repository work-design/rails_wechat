# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Passive_user_reply_message.html
module Wechat
  module Model::Reply
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :value, :string
      attribute :title, :string
      attribute :description, :string
      attribute :body, :json
      attribute :appid, :string, index: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :messaging, polymorphic: true, optional: true

      has_one_attached :media
    end

    def invoke_effect(request = nil, **options)
      self.value = value.to_s + options[:value].to_s
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
      r.merge!(FromUserName: app.user_name) if app
      r
    end

  end
end
