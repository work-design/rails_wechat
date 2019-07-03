module RailsWechat::WechatConfigTag
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    belongs_to :wechat_config
    belongs_to :wechat_tag
  end

  

end

