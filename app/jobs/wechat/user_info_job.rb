# frozen_string_literal: true

module Wechat
  class UserInfoJob < ApplicationJob

    def perform(wechat_user)
      wechat_user.sync_user_info
    end

  end
end
