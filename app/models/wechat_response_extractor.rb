class WechatResponseExtractor < ApplicationRecord
  include RailsWechat::WechatResponseExtractor
end unless defined? WechatResponseExtractor
