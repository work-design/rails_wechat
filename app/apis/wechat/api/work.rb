# frozen_string_literal: true
module Wechat::Api
  class Work < Base
    include Agent
    include Menu
    include User
    include Contact

    def initialize(app)
      super
      @agentid = app.agentid
    end

  end
end
