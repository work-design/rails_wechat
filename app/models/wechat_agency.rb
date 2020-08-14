class WechatAgency < ApplicationRecord
  include RailsWechat::WechatAgency
  include RailsWechat::AppSync
end unless defined? WechatAgency
