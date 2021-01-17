module Wechat
  class WechatApp < ApplicationRecord
    include Model::WechatApp
    include Model::AppSync
  end
end
