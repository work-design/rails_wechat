module Wechat
  class Share::WechatAppsController < Share::BaseController
    before_action :set_wechat_app, only: [:show]

    def index
      q_params = {}
      q_params.merge! params.permit(:id)

      @wechat_apps = WechatApp.shared.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def show
    end

    private
    def set_wechat_app
      @wechat_app = WechatApp.shared.find(params[:id])
    end

  end
end
