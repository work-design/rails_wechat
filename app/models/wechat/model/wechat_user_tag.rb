module Wechat
  module RailsWechat::WechatUserTag
    extend ActiveSupport::Concern

    included do
      belongs_to :wechat_user
      belongs_to :wechat_tag, counter_cache: true
      belongs_to :user_tagged, optional: true

      after_create_commit :sync_create_later
      after_destroy_commit :remove_from_wechat
    end

    def sync_create_later
      WechatUserTagJob.perform_later(self)
    end

    def sync_to_wechat
      if wechat_api
        wechat_api.tag_add_user(wechat_tag.tag_id, wechat_user.uid)
      end
    end

    def wechat_api
      @wechat_api ||= wechat_user.wechat_app&.api
    end

    def remove_from_wechat
      wechat_api.tag_del_user(wechat_tag.tag_id, wechat_user.uid) if wechat_api
    end

  end
end
