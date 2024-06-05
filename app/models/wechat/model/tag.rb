module Wechat
  module Model::Tag
    SYS_TAG = ['2'].freeze
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :name, :string
      attribute :count, :integer, default: 0
      attribute :user_tags_count, :integer, default: 0
      attribute :tag_id, :integer

      enum :kind, {
        normal: 'normal',
        inviting: 'inviting'
      }, default: 'normal'

      belongs_to :tagging, polymorphic: true, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :user_tag, optional: true

      has_many :user_tags, ->(o) { where(appid: o.appid) }, primary_key: :name, foreign_key: :tag_name, dependent: :destroy_async
      has_many :wechat_users, through: :user_tags
      has_many :requests, ->(o) { where(type: ['Wechat::ScanRequest', 'Wechat::SubscribeRequest'], body: o.name).order(id: :desc) }, foreign_key: :appid, primary_key: :appid

      validates :name, uniqueness: { scope: :appid }

      before_validation :sync_name
      before_validation :compute_kind, if: -> { name_changed? }
      after_create_commit :sync_to_wechat, if: -> { tag_id.blank? }
      after_update_commit :sync_to_wechat, if: -> { saved_change_to_name? }
      after_destroy_commit :remove_from_wechat, if: -> { tag_id.present? }
      after_save_commit :sync_to_wechat_later, if: -> { tag_id.blank? && saved_change_to_name? }
    end

    def sync_name
      self.name = tagging.name if tagging
    end

    def compute_kind
      if name.to_s.start_with?('auth_user_', 'org_member_')
        self.kind = 'inviting'
      end
    end

    def sync_to_wechat_later
      TagJob.perform_later(self)
    end

    def sync_to_wechat
      r = app.api.tag_create(self.name, self.tag_id)
      return unless r
      self.tag_id = r.dig('tag', 'id')
      self.save
    rescue Wechat::WechatError => e
      logger.info e.message
    end

    def remove_from_wechat
      app.api.tag_delete(self.tag_id)
    rescue Wechat::WechatError => e
      logger.info e.message
    end

    def can_destroy?
      SYS_TAG.include?(tag_id)
    end

  end
end
