module Wechat
  module Model::User
    extend ActiveSupport::Concern

    included do
      has_many :wechat_users, class_name: 'Wechat::WechatUser'
      has_many :wechat_program_users, class_name: 'Wechat::WechatProgramUser'
      has_many :wechat_subscribeds, ->{ where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::WechatSubscribed', through: :wechat_program_users
      has_many :wechat_registers, class_name: 'Wechat::WechatRegister', dependent: :destroy
    end

    def invite_qrcode(wechat_app)
      p = {
        appid: wechat_app.appid,
        match_value: "invite_by_#{id}"
      }
      res = WechatResponse.find_or_initialize_by(p)
      res.effective_type = 'TextReply'
      res.request_types = [
        'SubscribeRequest',
        'ScanRequest'
      ]
      res.expire_seconds ||= 2592000
      res.save
      res.qrcode_file_url
    end

  end
end
