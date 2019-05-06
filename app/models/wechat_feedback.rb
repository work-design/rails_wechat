class WechatFeedback < ApplicationRecord
  include RailsWechat::WechatFeedback
  include RailsWechat::Extractable
end unless defined? WechatFeedback
