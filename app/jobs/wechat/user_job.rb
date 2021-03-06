# frozen_string_literal: true

module Wechat
  class UserJob < ApplicationJob

    def perform(wechat_user)
      wechat_user.sync_remark_to_wechat
    end

  end
end
