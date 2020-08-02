class WechatResponseRequest < ApplicationRecord
  include RailsWechat::WechatResponseRequest
end unless defined? WechatResponseRequest
