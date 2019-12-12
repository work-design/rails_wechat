class WechatMessage < ApplicationRecord
  include RailsWechat::WechatMessage
end unless defined? WechatMessage
