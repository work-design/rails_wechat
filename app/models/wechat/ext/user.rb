module Wechat
  module Ext::User
    extend ActiveSupport::Concern
    include Ext::Handle

    included do
      has_many :wechat_users, class_name: 'Wechat::WechatUser'
      has_many :program_users, class_name: 'Wechat::ProgramUser'
      has_many :user_inviters, through: :wechat_users
      has_many :corp_users, class_name: 'Wechat::CorpUser'
      has_many :registers, class_name: 'Wechat::Register'
      has_many :medias, class_name: 'Wechat::Media'
      has_many :subscribes, ->{ where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :program_users
      has_many :scenes, as: :handle, class_name: 'Wechat::Scene'
    end

    def invite_scene!(app, organ_id:)
      scene = scenes.find_or_initialize_by(appid: app.appid, organ_id: organ_id)
      scene.check_refresh
      scene.save!
      scene
    end

  end
end
