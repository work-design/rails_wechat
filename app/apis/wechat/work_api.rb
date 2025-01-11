# frozen_string_literal: true
module Wechat
  class WorkApi < BaseApi
    include Agent
    include Contact
    include IdConvert
    include Kf
    include Media
    include Menu
    include User

    def initialize(app)
      super
      @agentid = app.agentid
    end

  end
end
