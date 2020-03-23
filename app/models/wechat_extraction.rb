class WechatExtraction < ApplicationRecord
  include RailsWechat::WechatExtraction
end unless defined? WechatExtraction
