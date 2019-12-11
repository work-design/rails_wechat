class WechatTemplate < ApplicationRecord
  include RailsWechat::WechatTemplate
end unless defined? WechatTemplate
