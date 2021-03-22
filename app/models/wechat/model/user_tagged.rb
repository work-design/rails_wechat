module Wechat
  module Model::UserTagged
    extend ActiveSupport::Concern

    included do
      has_many :wechat_user_tags
      has_many :tags, foreign_key: :user_tag_id, primary_key: :user_tag_id
      after_create_commit :sync_to_wechat_user_tag
    end

    def sync_to_wechat_user_tag
      user.oauth_users.where(type: 'WechatUser').each do |wechat_user|
        tag = tags.find_by(app_id: wechat_user.app&.id)
        next unless tag

        wut = wechat_user.wechat_user_tags.build(tag_id: tag.id)
        wut.save
      end
    end

  end
end
