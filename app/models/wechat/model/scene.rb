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

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :response, ->(o){ where(match_value: o.match_value) }, foreign_key: :appid, primary_key: :appid
      belongs_to :tag, ->(o){ where(name: o.match_value) }, foreign_key: :appid, primary_key: :appid

      has_many :app_menus, ->(o){ where(appid: o.appid) }, dependent: :destroy_async
      has_many :menus, -> { roots }, through: :app_menus

      before_validation :init_expire_at, if: -> { expire_seconds.present? && expire_seconds_changed? }
      before_validation :sync_from_app, if: -> { appid.present? && appid_changed? }
      after_save_commit :to_qrcode, if: -> { saved_change_to_match_value? }
      after_save_commit :refresh_when_expired, if: -> { saved_change_to_expire_at? }
    end

    def init_expire_at
      self.expire_at ||= Time.current + expire_seconds
    end

    def sync_from_app
      self.organ_id ||= app.organ_id
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
    end

    def qrcode_data_url
      return unless self.qrcode_url
      QrcodeHelper.data_url(self.qrcode_url)
    end

    def commit_to_wechat
      if ['Wechat::PublicApp', 'Wechat::ReadApp'].include? app.type
        get_public_qrcode
      elsif ['Wechat::ProgramApp'].include? app.type
        get_wxa_qrcode
      end

      self.save
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
      r = app.api.get_wxacode(query: program_query)
      self.qrcode_url = r
      r
    end

    def program_query
      {
        org_id: "org_#{organ_id}",
        path: "#{match_value.delete_prefix('/')}"
      }
    end

    def get_program_qrcode
      if expire_seconds
        self.expire_at = Time.current + expire_seconds
        expire = { is_expire: true, expire_type: 0, expire_time: expire_at.to_i }
      else
        expire = { is_expire: false }
      end

      r = app.api.generate_url(query: program_query.to_query, **expire)
      self.qrcode_url = r['url_link']
      r
    end

    def expired?(time = Time.current)
      expire_at && expire_at < time
    end

    def refresh_when_expired
      if expire_seconds == 2592000
        SceneRefreshJob.set(wait_until: expire_at - 3.days).perform_later(self)
      elsif match_value.start_with?('session_')
        SceneCleanJob.set(wait_until: expire_at).perform_later(self)
      end
    end

    def refresh(now = false)
      if expired? || now
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

  end
end
