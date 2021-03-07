# frozen_string_literal: true
module Wechat
  class WechatNoticeSendJob < ApplicationJob

    def perform(wechat_notice)
      wechat_notice.do_send
    end

  end
end
