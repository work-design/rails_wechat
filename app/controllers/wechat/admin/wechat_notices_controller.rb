module Wechat
  class Admin::WechatNoticesController < Admin::BaseController
    before_action :set_wechat_template
    before_action :set_wechat_notice, only: [:show, :edit, :update, :destroy]

    def index
      @wechat_notices = @wechat_template.wechat_notices.page(params[:page])
    end

    def new
      @wechat_notice = @wechat_template.wechat_notices.build
    end

    def create
      @wechat_notice = @wechat_template.wechat_notices.build(wechat_notice_params)

      unless @wechat_notice.save
        render :new, locals: { model: @wechat_notice }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @wechat_notice.assign_attributes(wechat_notice_params)

      unless @wechat_notice.save
        render :edit, locals: { model: @wechat_notice }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_notice.destroy
    end

    private
    def set_wechat_template
      @wechat_template = WechatTemplate.find params[:wechat_template_id]
    end

    def set_wechat_notice
      @wechat_notice = @wechat_template.wechat_notices.find(params[:id])
    end

    def wechat_notice_params
      params.fetch(:wechat_notice, {}).permit(
        :notifiable_type,
        :code,
        mappings: {}
      )
    end

  end
end
