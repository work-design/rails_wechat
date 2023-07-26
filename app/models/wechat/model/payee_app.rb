module Wechat
  module Model::PayeeApp
    extend ActiveSupport::Concern

    included do
      attribute :mch_id, :string, index: true
      attribute :appid, :string, index: true
      attribute :enabled, :boolean, default: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :agency, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :partner_payee, foreign_key: :mch_id, primary_key: :mch_id, optional: true
      belongs_to :mch_payee, foreign_key: :mch_id, primary_key: :mch_id, optional: true

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
      if partner_payee
        @api = WxPay::Api::Partner.new(payee: partner_payee, partner: partner_payee.partner, appid: appid)
      elsif mch_payee
        @api = WxPay::Api::Mch.new(payee: mch_payee, appid: appid)
      end
    end

  end
end
