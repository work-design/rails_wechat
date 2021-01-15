module Wechat
  module RailsWechat::WechatTag
    SYS_TAG = ['2'].freeze
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :count, :integer, default: 0
      attribute :wechat_user_tags_count, :integer, default: 0
      attribute :tag_id, :integer

      belongs_to :tagging, polymorphic: true, optional: true
      belongs_to :wechat_app
      belongs_to :user_tag, optional: true
      has_many :wechat_user_tags, dependent: :destroy
      has_many :wechat_users, through: :wechat_user_tags

      validates :name, uniqueness: { scope: :wechat_app_id }

      before_create :sync_name
      after_create_commit :sync_to_wechat, if: -> { tag_id.blank? }
      after_update_commit :sync_to_wechat, if: -> { saved_change_to_name? }
      after_destroy_commit :remove_from_wechat, if: -> { tag_id.present? }
    end

    def sync_name
      self.name = tagging.name if tagging
    end

    def sync_to_wechat
      r = wechat_app.api.tag_create(self.name, self.tag_id)
      return unless r
      tag = r['tag']
      self.tag_id = tag['id']
    rescue Wechat::WechatError => e
      logger.info e.message
    end

    def remove_from_wechat
      wechat_app.api.tag_delete(self.tag_id)
    rescue Wechat::WechatError => e
      logger.info e.message
    end

    def can_destroy?
      SYS_TAG.include?(tag_id)
    end

  end
end
