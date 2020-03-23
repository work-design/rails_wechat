class WechatExtractor < ApplicationRecord
  include RailsWechat::WechatExtractor
end unless defined? WechatExtractor
