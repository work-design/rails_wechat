class WechatReply < ApplicationRecord
  include RailsWechat::WechatReply
end unless defined? WechatReply
