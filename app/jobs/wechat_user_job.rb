# frozen_string_literal: true

class WechatUserJob < ApplicationJob

  def perform(wechat_user)
    wechat_user.sync_remark_to_wechat
  end

end
