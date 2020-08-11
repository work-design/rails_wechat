module RailsWechat::WechatService::ImageService
  extend ActiveSupport::Concern

  included do
    attribute :msgtype, :string, default: 'image'
  end

end
