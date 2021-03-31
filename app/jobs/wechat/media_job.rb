# frozen_string_literal: true
module Wechat
  class MediaJob < ApplicationJob

    def perform(media)
      media.store_entity
    end

  end
end
