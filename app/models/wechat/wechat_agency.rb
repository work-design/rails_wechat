module Wechat
  class WechatAgency < ApplicationRecord
    include RailsWechat::WechatAgency
    include RailsWechat::AppSync
  end
end
