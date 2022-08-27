module Wechat
  module Ext::Member
    extend ActiveSupport::Concern

    included do
      belongs_to :corp_user, ->(o) { where(organ_id: o.organ_id) }, class_name: 'Wechat::CorpUser', foreign_key: :identity, primary_key: :identity, optional: true

      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :account, source: :oauth_users
      has_many :program_users, class_name: 'Wechat::ProgramUser', through: :account, source: :oauth_users
      has_many :medias, class_name: 'Wechat::Media'
      has_many :subscribes, ->{ where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :program_users
    end

    def invite_scene(app, prefix = 'invite_member')
      scene = Scene.find_or_initialize_by(appid: app.appid, match_value: "#{prefix}_#{id}")
      scene.expire_seconds ||= 2592000
      scene.organ_id = app.organ_id
      scene.save
      scene
    end

  end
end
