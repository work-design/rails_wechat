module Wechat
  module Model::PayeeApp
    extend ActiveSupport::Concern

    included do
      attribute :mch_id, :string, index: true
      attribute :appid, :string, index: true
      attribute :enabled, :boolean, default: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :payee, foreign_key: :mch_id, primary_key: :mch_id

      has_many :receivers

      scope :enabled, -> { where(enabled: true) }

      validates :appid, uniqueness: { scope: :mch_id }

      after_update :set_enabled, if: -> { enabled? && saved_change_to_enabled? }
    end

    def set_enabled
      self.class.where.not(id: self.id).where(appid: self.appid).update_all(enabled: false)
    end

    def api
      return @api if defined? @api
      if payee.is_a?(PartnerPayee) && payee.partner
        @api = WxPay::Api::Partner.new(payee: payee, partner: payee.partner, appid: appid)
      else
        @api = WxPay::Api::Mch.new(payee: payee, appid: appid)
      end
    end

  end
end
