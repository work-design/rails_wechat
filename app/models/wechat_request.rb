class WechatRequest < ApplicationRecord
  include RailsWechat::WechatRequest
end unless defined? WechatRequest
