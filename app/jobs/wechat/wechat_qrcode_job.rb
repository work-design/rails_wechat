# frozen_string_literal: true
module Wechat
  class WechatQrcodeJob < ApplicationJob

    def perform(effective)
      effective.qrcode
    end

  end
end
