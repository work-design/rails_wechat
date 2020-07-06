module RailsWechat::WechatRegister
  extend ActiveSupport::Concern

  included do
    attribute :id_name, :string
    attribute :id_number, :string

    belongs_to :member
  end

end
