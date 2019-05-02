class WechatConfig < ApplicationRecord
  include RailsWechat::WechatConfig
end unless defined? WechatConfig
