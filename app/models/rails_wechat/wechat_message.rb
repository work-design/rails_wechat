module RailsWechat::WechatMessage
  extend ActiveSupport::Concern
  included do
    attribute :type, :string
    attribute :value, :string
    attribute :body, :json
    
    belongs_to :wechat_app
    belongs_to :messaging, polymorphic: true
  end

end
