module Wechat
  class QyWechatController < BaseController

    def login
      @app = WorkApp.default_where(default_params).take || WorkApp.global.take || current_organ.corps[0]
    end

  end
end
