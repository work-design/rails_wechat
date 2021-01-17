module Wechat
  class WechatAgency < ApplicationRecord
    include Model::WechatAgency
    include Model::AppSync
  end
end
