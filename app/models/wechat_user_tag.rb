class WechatUserTag < ApplicationRecord
  include RailsWechat::WechatUserTag
end unless defined? WechatUserTag
