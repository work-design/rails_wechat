module RailsWechat::Tagging
  extend ActiveSupport::Concern
  included do
    has_many :wechat_tags, as: :tagging, dependent: :nullify
  end
  
  
end
