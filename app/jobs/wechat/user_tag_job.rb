# frozen_string_literal: true

module Wechat
  class UserTagJob < ApplicationJob

    def perform(wechat_user_tag)
      wechat_user_tag.sync_to_wechat
    end

  end
end
