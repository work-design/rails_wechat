module RailsWechat::WechatRegister
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

    belongs_to :user
    belongs_to :organ
    belongs_to :member, foreign_key: :mobile, primary_key: :identity, optional: true
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true

    validates :mobile, presence: true, uniqueness: true

    has_one_attached :bind_qrcode

    enum state: {
      init: 'init',
      doing: 'doing',
      done: 'done'
    }

    after_initialize if: :new_record? do
      self.password = SecureRandom.urlsafe_base64
    end
    before_validation :sync_user, if: -> { mobile_changed? && member }
    before_save :compute_state, if: -> { appid_changed? }

    acts_as_notify only: [:id_name], methods: [:time, :bind_url, :hello, :remark]
  end

  def hello
    '您好，这是您注册公众号绑定管理员的二维码'
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

  def organ_appid
    organ.wechat_apps.default&.appid
  end

  def promoter
    open_id = user.wechat_users.find_by(app_id: organ_appid)&.uid
    if open_id
      wr = WechatRequest.where(open_id: open_id).default_where('body-ll': 'invite_member_').order(id: :desc).first
      member_id = wr&.body.to_s.delete_prefix('invite_member_')
      Member.find_by id: member_id
    end
  end

  def notify_promoter
    return unless promoter
    to_notification(
      receiver: promoter.user,
      title: '二维码已更新，请邀请对方绑定',
      link: bind_url,
      organ_id: promoter.organ_id
    )
  end

  def notify_owner
    to_notification(
      receiver: user,
      title: '二维码已更新，请点击',
      link: bind_url,
      organ_id: organ_id
    )
  end

  def notify_qrcode
    notify_owner
    notify_promoter
  end

  def sync_user
    self.user_id ||= member.user_id
  end

end
