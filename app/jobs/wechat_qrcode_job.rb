# frozen_string_literal: true

class WechatQrcodeJob < ApplicationJob
  
  def perform(effective)
    effective.qrcode
  end
  
end
