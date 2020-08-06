module RailsWechat::Member
  extend ActiveSupport::Concern

  included do
    has_many :wechat_registers, foreign_key: :mobile, primary_key: :identity, dependent: :destroy
  end

end
