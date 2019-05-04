class WechatResponse < ApplicationRecord
  include RailsWechat::WechatResponse
end unless defined? WechatResponse
