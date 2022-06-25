module Wechat
  class QyWechatController < BaseController

    def login
      @app = WorkApp.find 3
    end

  end
end
