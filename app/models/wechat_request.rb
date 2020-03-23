class WechatRequest < ApplicationRecord
  include RailsWechat::WechatRequest
  include WechatRequest::Extend
end unless defined? WechatRequest
