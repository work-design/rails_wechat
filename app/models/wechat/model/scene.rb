module Wechat
  module Model::Scene
    extend ActiveSupport::Concern

    included do
      attribute :match_value, :string
      attribute :expire_seconds, :integer
      attribute :expire_at, :datetime
      attribute :qrcode_ticket, :string
      attribute :qrcode_url, :string
      attribute :appid, :string, index: true

      belongs_to :organ, class_name: 'Org::Organ'

      belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid
      belongs_to :wechat_response, optional: true

      has_one_attached :qrcode_file

      before_validation do
        self.expire_at ||= Time.current + expire_seconds if expire_seconds
      end
      after_save_commit :to_qrcode, if: -> { saved_change_to_match_value? }
    end

    def to_qrcode
      commit_to_wechat if expired?
      persist_to_file
    end

    def persist_to_file
      return unless self.qrcode_url
      file = QrcodeHelper.code_file self.qrcode_url
      self.qrcode_file.attach io: file, filename: self.qrcode_url
    end

    def qrcode_file_url
      qrcode_file.url if qrcode_file.attachment.present?
    end

    def commit_to_wechat
      # 默认: 2592000 ，即 30 天
      if expire_seconds
        r = wechat_app.api.qrcode_create_scene self.match_value, expire_seconds
        self.expire_at = Time.current + expire_seconds
      elsif self.qrcode_ticket.blank?
        r = wechat_app.api.qrcode_create_limit_scene self.match_value
      else
        r = {}
      end

      self.qrcode_ticket = r['ticket']
      self.qrcode_url = r['url']
      self.save
      r
    end

    def expired?(time = Time.current)
      expire_at && expire_at < time
    end

    def refresh
      if expired?
        to_qrcode
      end
      self
    end

  end
end
