module Wechat
  module Model::UserTag
    extend ActiveSupport::Concern

    included do
      belongs_to :wechat_user
      belongs_to :tag, counter_cache: true
      belongs_to :user_tagged, optional: true

      after_create_commit :sync_create_later
      after_destroy_commit :remove_from_wechat_later
    end

    def sync_create_later
      UserTagJob.perform_later(self)
    end

    def remove_from_wechat_later
      UserTagRemoveJob.perform_later(self)
    end

    def sync_to_wechat
      if wechat_api
        wechat_api.tag_add_user(tag.tag_id, wechat_user.uid)
      end
    end

    def wechat_api
      @wechat_api ||= wechat_user.app&.api
    end

    def remove_from_wechat
      wechat_api.tag_del_user(tag.tag_id, wechat_user.uid) if wechat_api
    end

  end
end
