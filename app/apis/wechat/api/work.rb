# frozen_string_literal: true
module Wechat::Api
  class Work < Base
    include Agent
    include Menu
    include User
    include Contact
    include Media
    include IdConvert

    def initialize(app)
      super
      @agentid = app.agentid
    end

  end
end
