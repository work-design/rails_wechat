module RailsWechat::WechatRegister
  extend ActiveSupport::Concern

  included do
    attribute :id_name, :string
    attribute :id_number, :string
    attribute :state, :string, default: 'init'

    belongs_to :member

    enum state: {
      init: 'init',
      doing: 'doing',
      done: 'done'
    }
  end

end
