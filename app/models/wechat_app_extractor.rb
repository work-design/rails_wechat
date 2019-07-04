class WechatConfigExtractor < ApplicationRecord
  include RailsWechat::WechatConfigExtractor
end unless defined? WechatConfigExtractor

