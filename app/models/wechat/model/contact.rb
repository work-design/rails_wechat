module Wechat
  module Model::Contact
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :user_id, :string
      attribute :part_id, :string
      attribute :config_id, :string
      attribute :qr_code, :string
      attribute :remark, :string
      attribute :state, :string
      attribute :skip_verify, :boolean, default: true

      belongs_to :suite
      belongs_to :corp, ->(o){ where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id, optional: true
      belongs_to :corp_user, ->(o){ where(suite_id: o.suite_id, corp_id: o.corp_id) }, foreign_key: :user_id, primary_key: :user_id, optional: true

      before_create :add_to_wx
      after_save_commit :sync_to_wx, if: -> { (saved_changes.keys & ['remark', 'state', 'skip_verify']).present? }
      after_destroy_commit :prune
    end

    def prune
      corp && corp.api.del_contact_way(config_id)
    end

    def add_to_wx
      return unless corp
      r = corp.api.add_contact_way(
        user: user_id,
        remark: remark,
        state: state,
        skip_verify: skip_verify
      )
      self.assign_attributes r.slice('config_id', 'qr_code')
      self
    end

    def sync_to_wx
      return unless corp
      corp.api.update_contact_way(
        config_id,
        remark: remark,
        state: state,
        skip_verify: skip_verify
      )
    end

  end
end

