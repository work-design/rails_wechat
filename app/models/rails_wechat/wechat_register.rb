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

    acts_as_notify only: [:id_name]
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

  def notify_qrcode
    to_notification(
      receiver: user,
      title: '二维码已更新，请点击',
      link: bind_qrcode.url,
      organ_id: 1  # todo 演示
    )
  end

  def sync_user
    self.user_id ||= member.user_id
  end

end
