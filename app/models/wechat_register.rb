class WechatRegister < ApplicationRecord
  include RailsWechat::WechatRegister
end unless defined? WechatRegister
