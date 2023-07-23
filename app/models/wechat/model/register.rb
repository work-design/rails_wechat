module Wechat
  module Model::Register
    extend ActiveSupport::Concern

    included do
      attribute :id_name, :string
      attribute :id_number, :string
      attribute :email_code, :string
      attribute :state, :string, default: 'init'
      attribute :appid, :string
      attribute :password, :string
      attribute :mobile, :string
      attribute :mobile_code, :string

      belongs_to :user, optional: true
      belongs_to :organ, class_name: 'Wechat::Organ', optional: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      validates :mobile, presence: true, uniqueness: true

      has_one_attached :bind_qrcode
      has_one_attached :qrcode

      enum state: {
        init: 'init',
        doing: 'doing',
        done: 'done'
      }

      after_initialize if: :new_record? do
        self.password = SecureRandom.urlsafe_base64
      end
      before_save :compute_state, if: -> { appid_changed? }

      acts_as_notify only: [:id_name], methods: [:time, :bind_url, :remark]
      acts_as_notify :code, only: [:id_name, :mobile], methods: [:hello_code, :keyword1_code, :remark_code]
      acts_as_notify :auth, only: [:id_name], methods: [:auth_keyword2, :state_i18n, :auth_remark]
    end

    def time
      Time.current.to_s
    end

    def bind_url
      bind_qrcode.url
    end

    def remark
      '此二维码不支持图片识别，可复制链接在电脑或其他手机上访问后再扫一扫！'
    end

    def hello_code
      '您好，我们正在协助您注册微信公众号'
    end

    def keyword1_code
      '手机号验证码'
    end

    def remark_code
      '请点击链接，输入您收到的验证码。'
    end

    def compute_state
      if appid.present?
        self.state = 'done'
      else
        self.state = 'doing'
      end
    end

    def email
      "#{mobile}@#{RailsWechat.config.email_domain}"
    end

    def organ_app
      organ.apps.default
    end

    def promoter
      open_id = user.wechat_users.find_by(appid: organ_app&.appid)&.uid
      if open_id
        wr = Request.where(open_id: open_id).default_where('body-ll': 'invite_member_').order(id: :desc).first
        member_id = wr&.body.to_s.delete_prefix('invite_member_')
        Member.find_by id: member_id
      end
    end

    def notify_promoter
      return unless promoter
      to_notification(
        user: promoter.user,
        title: '管理员绑定二维码已生成，请邀请对方绑定',
        link: bind_url,
        organ_id: promoter.organ_id
      )
    end

    def notify_owner
      to_notification(
        user: user,
        title: '您好，这是您注册公众号绑定管理员的二维码',
        link: bind_url,
        organ_id: organ_id
      )
    end

    def notify_mobile_code
      to_notification(
        user: user,
        code: 'code',
        title: '手机验证码已下发，该验证码用于注册微信公众号',
        link: Rails.application.routes.url_for(action: 'code', id: id, subdomain: organ_app&.subdomain),
        organ_id: organ_id
      )
    end

    def notify_auth
      to_notification(
        user: user,
        code: 'auth',
        title: '授权服务',
        link: Platform.first.click_auth_url,
        organ_id: organ_id
      )
    end

    def notify_qrcode
      notify_owner
      notify_promoter
    end

  end
end
