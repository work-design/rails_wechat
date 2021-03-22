# frozen_string_literal: true
module Wechat
  class QrcodeJob < ApplicationJob

    def perform(effective)
      effective.qrcode
    end

  end
end
