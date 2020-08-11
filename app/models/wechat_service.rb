class WechatService < ApplicationRecord
  include RailsWechat::WechatService
end unless defined? WechatService
