# frozen_string_literal: true

class WechatUserTagJob < ApplicationJob

  def perform(wechat_user_tag)
    wechat_user_tag.sync_to_wechat
  end

end
