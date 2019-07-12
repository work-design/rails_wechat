# frozen_string_literal: true

class WechatAnnunciateJob < ApplicationJob
  
  def perform(annunciate)
    annunciate.to_wechat
  end
  
end
