class WechatConfigTag < ApplicationRecord
  include RailsWechat::WechatConfigTag
end unless defined? WechatConfigTag
