class WechatApp < ApplicationRecord
  include RailsWechat::WechatApp
  include RailsWechat::AppSync
end unless defined? WechatApp
