module Wechat
  module Model::PayeeApp
    extend ActiveSupport::Concern

    included do
      attribute :mch_id, :string, index: true
      attribute :appid, :string, index: true
      attribute :enabled, :boolean, default: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :payee, foreign_key: :mch_id, primary_key: :mch_id, optional: true

      has_many :receivers

      scope :enabled, -> { where(enabled: true) }

      validates :appid, uniqueness: { scope: :mch_id }

      before_validation :sync_organ, if: -> { mch_id_changed? }
      after_update :set_enabled, if: -> { enabled? && saved_change_to_enabled? }
    end

    def sync_organ
      self.organ_id = payee.organ_id
    end

    def set_enabled
      self.class.where.not(id: self.id).where(appid: self.appid).update_all(enabled: false)
    end

    def api
      return @api if defined? @api
      if payee.is_a?(PartnerPayee)
        @api = WxPay::PartnerApi.new(payee: payee, partner: payee.partner, appid: appid)
      else
        @api = WxPay::MchApi.new(payee: payee, appid: appid)
      end
    end

  end
end
