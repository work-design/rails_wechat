module RailsWechat::Member
  extend ActiveSupport::Concern

  included do
    has_many :wechat_registers, dependent: :destroy
  end

end
