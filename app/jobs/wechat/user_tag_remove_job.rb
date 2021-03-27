# frozen_string_literal: true

module Wechat
  class UserTagRemoveJob < ApplicationJob

    def perform(wechat_user_tag)
      wechat_user_tag.remove_from_wechat
    end

  end
end
