# frozen_string_literal: true

class WechatUserInfoJob < ApplicationJob

  def perform(wechat_user)
    wechat_user.sync_user_info
  end

end
