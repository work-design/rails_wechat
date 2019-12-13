class WechatNotice < ApplicationRecord
  include RailsWechat::WechatNotice
end unless defined? WechatNotice
