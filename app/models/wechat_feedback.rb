class WechatFeedback < ApplicationRecord
  include RailsWechat::WechatFeedback
end unless defined? WechatFeedback
