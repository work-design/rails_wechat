module RailsWechat::WechatRegister
  extend ActiveSupport::Concern

  included do
    attribute :id_name, :string
    attribute :id_number, :string
    attribute :email_code, :string
    attribute :bind_url, :string
    attribute :state, :string, default: 'init'
    attribute :appid, :string
    attribute :password, :string
    attribute :mobile_code, :string

    belongs_to :member
    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid, optional: true

    enum state: {
      init: 'init',
      doing: 'doing',
      done: 'done'
    }

    after_initialize if: :new_record? do
      self.password = SecureRandom.urlsafe_base64
    end
    before_save :compute_state, if: -> { appid_changed? }
  end

  def compute_state
    if appid.present?
      self.state = 'done'
    else
      self.state = 'doing'
    end
  end

  def email
    "#{id}@#{RailsWechat.config.email_domain}"
  end

end
