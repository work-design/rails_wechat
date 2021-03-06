module Wechat
  module Model::Scene
    extend ActiveSupport::Concern

    included do
      attribute :match_value, :string
      attribute :expire_seconds, :integer  # 默认: 2592000 ，即 30 天
      attribute :expire_at, :datetime
      attribute :qrcode_ticket, :string
      attribute :qrcode_url, :string
      attribute :appid, :string, index: true
      attribute :menu_id, :string

      belongs_to :organ, class_name: 'Org::Organ'

      belongs_to :app, foreign_key: :appid, primary_key: :appid

      has_one :response, ->(o){ where(match_value: o.match_value) }, primary_key: :appid, foreign_key: :appid
      has_one :tag, ->(o){ where(name: o.match_value) }, primary_key: :appid, foreign_key: :appid
      has_many :scene_menus, dependent: :destroy
      has_many :menus, through: :scene_menus

      has_one_attached :qrcode_file

      before_validation do
        self.expire_at ||= Time.current + expire_seconds if expire_seconds
      end
      after_save_commit :to_qrcode, if: -> { saved_change_to_match_value? }
    end

    def init_response
      res = response || build_response
      res.effective_type = 'Wechat::TextReply'
      res.request_types = [
        'Wechat::SubscribeRequest',
        'Wechat::ScanRequest'
      ]
      res.save
      res
    end

    def to_qrcode
      commit_to_wechat
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
      if expire_seconds
        r = app.api.qrcode_create_scene self.match_value, expire_seconds
      else
        r = app.api.qrcode_create_limit_scene self.match_value
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
        self.expire_at = Time.current + expire_seconds
        to_qrcode
      end
      self
    end

    def sync_menu
      menu_delete
      r = app.api.menu_addconditional menu
      self.menu_id = r['menuid']
      self.save
      r
    end

    def menu_delete
      app.api.menu_delconditional(menu_id) if menu_id.present?
    end

    def scene_menus
      menus.as_json
    end

    def menu
      {
        button: app.default_menus + app.within_menus + scene_menus,
        matchrule: {
          tag_id: tag.tag_id.to_s
        }
      }
    end

  end
end
