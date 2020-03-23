class WechatRequestReply < ApplicationRecord
  include RailsWechat::WechatRequestReply
end unless defined? WechatRequestReply
