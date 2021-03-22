# frozen_string_literal: true
module Wechat
  class TagJob < ApplicationJob

    def perform(user_tag)
      user_tag.sync_tag
    end

  end
end
