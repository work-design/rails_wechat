module Wechat
  class QyWechatController < BaseController

    def login
      @app = WorkApp.default_where(default_params).take
    end

  end
end
