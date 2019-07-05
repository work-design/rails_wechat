class WechatAppExtractor < ApplicationRecord
  include RailsWechat::WechatAppExtractor
end unless defined? WechatAppExtractor

