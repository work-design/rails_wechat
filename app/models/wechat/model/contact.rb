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
      attribute :suite_id, :string

      belongs_to :source, class_name: 'Crm::Source', foreign_key: :state, primary_key: :name, optional: true

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id
      belongs_to :corp, ->(o){ where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id, optional: true
      belongs_to :corp_user, ->(o){ where(suite_id: o.suite_id, corp_id: o.corp_id) }, foreign_key: :user_id, primary_key: :user_id, optional: true

      has_one :source_contact, ->(o){ where(source_id: o.source.id) }, class_name: 'Crm::SourceContact'
      has_many :source_contacts, ->(o){ where(source_id: o.source.id) }, class_name: 'Crm::SourceContact'

      # 需要作为水印素材使用，故需要同步到对象存储服务
      has_one_attached :file

      before_create :add_to_wx
      after_save_commit :sync_to_wx, if: -> { (saved_changes.keys & ['remark', 'state', 'skip_verify']).present? }
      after_save_commit :sync_to_storage, if: -> { saved_change_to_qr_code? }
      after_destroy_commit :prune
    end

    def prune
      corp && corp.api.del_contact_way(config_id)
    end

    def info
      corp.api.get_contact_way(config_id)
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
      r
    end

    def sync_to_storage
      self.file.url_sync(qr_code)
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

