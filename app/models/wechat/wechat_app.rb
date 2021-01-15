module Wechat
  class WechatApp < ApplicationRecord
    include RailsWechat::WechatApp
    include RailsWechat::AppSync
  end
end
