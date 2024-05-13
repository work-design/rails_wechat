module Wechat
  module Model::Scene
    extend ActiveSupport::Concern

    included do
      attribute :match_value, :string
      attribute :tag_name, :string
      attribute :expire_seconds, :integer, default: 2592000  # 默认: 2592000 ，即 30 天
      attribute :expire_at, :datetime
      attribute :qrcode_ticket, :string
      attribute :qrcode_url, :string
      attribute :appid, :string, index: true
      attribute :menu_id, :string

      enum env_version: {
        release: 'release',
        trial: 'trial',
        develop: 'develop'
      }, _default: 'release', _prefix: true

      enum aim: {
        login: 'login',
        invite_user: 'invite_user',
        invite_member: 'invite_member',
        invite_contact: 'invite_contact',
        prepayment: 'prepayment',  # 钱包充值场景
        unknown: 'unknown'
      }, _default: 'unknown', _prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :handle, polymorphic: true, optional: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :response, ->(o) { where(appid: o.appid) }, foreign_key: :match_value, primary_key: :match_value, optional: true
      belongs_to :tag, ->(o) { where(appid: o.appid) }, foreign_key: :tag_name, primary_key: :name, optional: true

      has_many :menu_apps, ->(o) { where(appid: o.appid) }, dependent: :destroy_async
      has_many :menus, -> { roots }, through: :menu_apps
      has_many :requests, ->(o) { where(type: ['Wechat::ScanRequest', 'Wechat::SubscribeRequest'], aim: o.aim, handle_id: o.handle_id, scene_organ_id: o.organ_id) }, primary_key: :appid, foreign_key: :appid

      has_one_attached :qrcode

      before_validation :sync_from_app, if: -> { organ_id.blank? && appid.present? && appid_changed? }
      before_validation :init_match_value, if: -> { new_record? && handle }
      after_save_commit :to_qrcode!, if: -> { (saved_changes.keys & ['match_value', 'expire_at']).present? }
      after_save_commit :refresh_when_expired, if: -> { saved_change_to_expire_at? }
      after_create_commit :clean_when_expired, if: -> { aim_login? }
    end

    def sync_from_app
      self.organ_id ||= app.organ_id
    end

    def init_match_value
      self.match_value = "#{aim}_#{handle_id}_#{organ_id}_#{tag_name}"
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

    def to_qrcode!
      commit_to_wechat
      self.save!
    end

    def qrcode_data_url
      if ['Wechat::ProgramApp', 'Wechat::ProgramAgency'].include?(app.type)
        if qrcode.attached?
          qrcode.url
        else
          qrcode_url
        end
      else
        if qrcode_url
          QrcodeHelper.data_url(self.qrcode_url)
        else
          Rails.logger.debug "Scene:#{id} qrcode nil"
        end
      end
    end

    def commit_to_wechat
      if ['Wechat::PublicApp', 'Wechat::PublicAgency', 'Wechat::ReadApp'].include? app.type
        get_public_qrcode
      elsif ['Wechat::ProgramApp', 'Wechat::ProgramAgency'].include? app.type
        get_wxa_qrcode
      end
      self
    end

    def get_public_qrcode
      if expire_seconds
        r = app.api.qrcode_create_scene self.match_value, expire_seconds
      else
        r = app.api.qrcode_create_limit_scene self.match_value
      end
      self.qrcode_ticket = r['ticket']
      self.qrcode_url = r['url']
      r
    end

    def get_wxa_qrcode
      options = { env_version: env_version }
      r = app.api.get_wxacode_unlimit(match_value, **options)
      begin
        self.qrcode.attach io: r, filename: "#{match_value}"
      rescue => e
      end
      r
    end

    def program_query
      "path=#{match_value}"
    end

    def get_program_qrcode
      if expire_seconds
        self.expire_at = Time.current + expire_seconds
        expire = { is_expire: true, expire_type: 0, expire_time: expire_at.to_i }
      else
        expire = { is_expire: false }
      end

      r = app.api.generate_url(query: program_query, **expire)
      self.qrcode_url = r['url_link']
      r
    end

    def expired?(time = Time.current)
      expire_at && expire_at < time
    end

    def refresh_when_expired
      SceneCleanJob.set(wait_until: expire_at).perform_later(self)
    end

    def check_refresh(now = false)
      if expired? || now
        self.expire_at = Time.current + expire_seconds
      end
    end

    def sync_menu
      menu_delete
      r = app.api.menu_addconditional menu
      self.menu_id = r['menuid']
      self.save
      r
    end

    def get_menu
      r = app.api.menu
      Array(r['conditionalmenu']).find(&->(i){ i['menuid'].to_s == menu_id })
    end

    def menu_delete
      app.api.menu_delconditional(menu_id) if menu_id.present?
    end

    def had_menus
      menus.as_json
    end

    def menu
      {
        button: app.default_menus + app.within_menus + had_menus,
        matchrule: {
          tag_id: tag.tag_id.to_s
        }
      }
    end

    def clean_when_expired
      SceneCleanJob.set(wait_until: expire_at).perform_later(self)
    end

    class_methods do

      def handle_types
        distinct.pluck(:handle_type).compact
      end

    end

  end
end
