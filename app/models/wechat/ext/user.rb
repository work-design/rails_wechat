module Wechat
  module Ext::User
    extend ActiveSupport::Concern

    included do
      has_many :wechat_users, class_name: 'Wechat::WechatUser'
      has_many :wechat_program_users, class_name: 'Wechat::WechatProgramUser'
      has_many :subscribes, ->{ where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :wechat_program_users
    end

    def invite_scene(app)
      scene = Scene.find_or_initialize_by(appid: app.appid, match_value: "invite_by_user_#{id}")
      scene.expire_seconds ||= 2592000
      scene.organ_id = app.organ_id
      scene.save
      scene
    end

  end
end
