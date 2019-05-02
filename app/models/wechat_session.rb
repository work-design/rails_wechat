class WechatSession < ApplicationRecord
  include RailsWechat::WechatSession
end unless defined? WechatSession
