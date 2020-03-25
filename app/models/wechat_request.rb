class WechatRequest < ApplicationRecord
  include RailsWechat::WechatRequest
  include WechatRequestExtend
end unless defined? WechatRequest
