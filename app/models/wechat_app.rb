class WechatApp < ApplicationRecord
  include RailsWechat::WechatApp
end unless defined? WechatApp
