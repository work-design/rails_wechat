module Wechat
  module Model::WechatService
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :msgtype, :string
      attribute :value, :string
      attribute :appid, :string
      attribute :open_id, :string
      attribute :body, :json

      belongs_to :wechat_request, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
      belongs_to :wechat_agency, foreign_key: :appid, primary_key: :appid, optional: true

      after_initialize if: :new_record? do
        if wechat_request
          self.appid = wechat_request.appid
          self.open_id = wechat_request.open_id
        end
      end
    end

    def do_send
      wechat_agency.api.message_custom_send to_wechat
    end

    def content
      {}
    end

    def to_wechat
      {
        touser: open_id,
        msgtype: msgtype,
      }.merge! content
    end

  end
end
