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

      enum aim: {
        login: 'login',
        invite_user: 'invite_user',
        invite_member: 'invite_member',
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

      has_one_attached :qrcode

      before_validation :sync_from_app, if: -> { organ_id.blank? && appid.present? && appid_changed? }
      before_validation :init_match_value, if: -> { new_record? && handle }
      after_save_commit :to_qrcode!, if: -> { saved_change_to_match_value? }
      after_save_commit :refresh_when_expired, if: -> { saved_change_to_expire_at? }
    end

    def sync_from_app
      self.organ_id ||= app.organ_id
    end

    def init_match_value
      self.match_value = "#{handle_type.downcase.gsub('::', '_')}_#{handle_id}_#{organ_id}"
      self.tag_name = "org_#{organ_id}"
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
      self.save
    end

    def qrcode_data_url
      if ['Wechat::ProgramApp'].include?(app.type)
        if qrcode.attached?
          qrcode.url
        else
          qrcode_url
        end
      else
        QrcodeHelper.data_url(self.qrcode_url) if qrcode_url
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
      self.expire_at = Time.current + r['expire_seconds']
      r
    end

    def get_wxa_qrcode
      r = app.api.get_wxacode_unlimit(program_query.to_query)
      self.qrcode.attach io: r, filename: "#{match_value}"
      r
    end

    def program_query
      {
        org_id: "#{organ_id}",
        path: "#{organ.redirect_path.delete_prefix('/')}"
      }.compact_blank
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
      SceneCleanJob.set(wait_until: expire_at).perform_later(self)
    end

    def refresh!(now = false)
      if expired? || now
        to_qrcode!
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

    class_methods do

      def handle_types
        distinct.pluck(:handle_type).compact
      end

    end

  end
end
