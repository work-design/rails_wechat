module RailsWechat::WechatService
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
  end


end
