module RailsWechat::WechatRegister
  extend ActiveSupport::Concern

  included do
    attribute :id_name, :string
    attribute :id_number, :string
    attribute :state, :string, default: 'init'
    attribute :appid, :string

    belongs_to :member
    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid, optional: true

    enum state: {
      init: 'init',
      doing: 'doing',
      done: 'done'
    }

    before_save :compute_state, if: -> { appid_changed? }
  end

  def compute_state
    if appid.present?
      self.state = 'done'
    else
      self.state = 'doing'
    end
  end

end
