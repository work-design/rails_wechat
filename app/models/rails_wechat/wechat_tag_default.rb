module RailsWechat::WechatTagDefault
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :default_type, :string
  end

  

end

