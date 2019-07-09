class WechatTagDefault < ApplicationRecord
  include RailsWechat::WechatTagDefault
  include RailsWechat::Tagging
end unless defined? WechatTagDefault
