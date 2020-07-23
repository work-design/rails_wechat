class WechatAgency < ApplicationRecord
  include RailsWechat::WechatAgency
end unless defined? WechatAgency
