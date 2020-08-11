module RailsWechat::WechatService::VideoService
  extend ActiveSupport::Concern

  included do
    attribute :msgtype, :string, default: 'video'
  end

end
