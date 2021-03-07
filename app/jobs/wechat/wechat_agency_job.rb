module Wechat
  class WechatAgencyJob < ApplicationJob

    def perform(wechat_agency)
      wechat_agency.store_info
    end

  end
end
