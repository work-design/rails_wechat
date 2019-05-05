module RailsWechat::Organ
  extend ActiveSupport::Concern
  included do
    attribute :limit_wechat, :integer, default: 1
    has_many :wechat_configs, dependent: :destroy
  end
  
end
