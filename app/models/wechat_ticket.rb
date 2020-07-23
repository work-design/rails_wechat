class WechatTicket < ApplicationRecord
  include RailsWechat::WechatTicket
end unless defined? WechatTicket
