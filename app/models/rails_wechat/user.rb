module RailsWechat::User
  extend ActiveSupport::Concern

  included do
    has_many :wechat_users
    has_many :wechat_program_users
    has_many :wechat_subscribeds, ->{ where(sending_at: nil).order(id: :asc) }, through: :wechat_program_users
  end

end
