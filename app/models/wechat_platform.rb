class WechatPlatform < ApplicationRecord
  include RailsWechat::WechatPlatform
end unless defined? WechatPlatform
