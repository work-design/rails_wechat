module RailsWechat::WechatService::TextService
  extend ActiveSupport::Concern

  included do
    attribute :msgtype, :string, default: 'text'
  end

end
