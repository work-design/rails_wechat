class WechatTag < ApplicationRecord
  include RailsWechat::WechatTag
end unless defined? WechatTag
