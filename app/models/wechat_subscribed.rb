class WechatSubscribed < ApplicationRecord
  include RailsWechat::WechatSubscribed
end unless defined? WechatSubscribed
