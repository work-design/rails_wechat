module Wechat
  class QyWechatController < BaseController

    def login
      @app = Agent.default_where(default_params).take || current_organ.corps[0]
    end

  end
end
