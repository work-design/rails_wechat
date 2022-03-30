module Wechat
  module Model::UserTag
    extend ActiveSupport::Concern

    included do
      attribute :tag_name, :string, index: true
      attribute :appid, :string, index: true
      attribute :open_id, :string, index: true
      attribute :synced, :boolean, default: false

      belongs_to :member_inviter, class_name: 'Org::Member', optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid
      belongs_to :tag, ->(o){ where(appid: o.appid) }, foreign_key: :tag_name, primary_key: :name, counter_cache: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :user_tagged, optional: true

      before_save :sync_inviter, if: -> { tag_name.start_with?('invite_member_') && tag_name_changed? }
      after_create_commit :sync_create_later
      after_destroy_commit :remove_from_wechat
    end

    def sync_inviter
      self.member_inviter_id = tag_name.delete_prefix('invite_member_')
    end

    def sync_create_later
      UserTagJob.perform_later(self)
    end

    def sync_to_wechat
      if wechat_api && tag.tag_id.present?
        r = wechat_api.tag_add_user(tag.tag_id, wechat_user.uid)
        if r['errcode'] == 0
          self.update synced: true
        end
      end
    end

    def wechat_api
      @wechat_api ||= app&.api
    end

    def remove_from_wechat
      wechat_api.tag_del_user(tag.tag_id, open_id) if wechat_api
    end

  end
end
