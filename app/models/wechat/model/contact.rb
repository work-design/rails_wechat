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

      belongs_to :corp, foreign_key: :corp_id, primary_key: :corp_id, optional: true

      after_save_commit :sync_to_wx, if: -> { (saved_changes.keys & ['remark', 'state', 'skip_verify']).present? }
      after_destroy_commit :prune
    end

    def prune
      corp && corp.api.del_contact_way(config_id)
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

