class WechatMenu < ApplicationRecord
  include RailsWechat::WechatMenu
end unless defined? WechatMenu
