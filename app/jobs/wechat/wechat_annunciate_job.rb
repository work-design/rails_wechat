# frozen_string_literal: true
module Wechat
  class WechatAnnunciateJob < ApplicationJob

    def perform(annunciate)
      annunciate.to_wechat
    end

  end
end
