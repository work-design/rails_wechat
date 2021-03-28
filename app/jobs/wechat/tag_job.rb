# frozen_string_literal: true
module Wechat
  class TagJob < ApplicationJob

    def perform(tag)
      tag.sync_to_wechat
    end

  end
end
