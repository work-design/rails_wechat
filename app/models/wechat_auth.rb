class WechatAuth < ApplicationRecord
  include RailsWechat::WechatAuth
end unless defined? WechatAuth
