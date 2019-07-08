module RailsWechat::WechatTagDefault
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :default_type, :string
    
    has_many :wechat_tags, dependent: :nullify
  end
  
end

