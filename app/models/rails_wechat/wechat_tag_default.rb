module RailsWechat::WechatTagDefault
  extend ActiveSupport::Concern
  included do
    attribute :default_type, :string
  end
  
end

