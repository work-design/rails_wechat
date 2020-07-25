class WechatReceived < ApplicationRecord
  include RailsWechat::WechatReceived
end unless defined? WechatReceived
