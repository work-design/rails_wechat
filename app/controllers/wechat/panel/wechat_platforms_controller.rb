module Wechat
  class Panel::WechatPlatformsController < Panel::BaseController
    before_action :set_wechat_platform, only: [:show, :edit, :update, :destroy]

    def index
      @wechat_platforms = WechatPlatform.page(params[:page])
    end

    def new
      @wechat_platform = WechatPlatform.new
    end

    def create
      @wechat_platform = WechatPlatform.new(wechat_platform_params)

      unless @wechat_platform.save
        render :new, locals: { model: @wechat_platform }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @wechat_platform.assign_attributes(wechat_platform_params)

      unless @wechat_platform.save
        render :edit, locals: { model: @wechat_platform }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_platform.destroy
    end

    private
    def set_wechat_platform
      @wechat_platform = WechatPlatform.find(params[:id])
    end

    def wechat_platform_params
      params.fetch(:wechat_platform, {}).permit(
        :name,
        :appid,
        :secret,
        :verify_ticket,
        :token,
        :encoding_aes_key
      )
    end

  end
end
