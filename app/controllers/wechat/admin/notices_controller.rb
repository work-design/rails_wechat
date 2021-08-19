module Wechat
  class Admin::NoticesController < Admin::BaseController
    before_action :set_template
    before_action :set_notice, only: [:show, :edit, :update, :destroy]

    def index
      @notices = @template.notices.page(params[:page])
    end

    def new
      @notice = @template.notices.build
    end

    def create
      @notice = @template.notices.build(notice_params)

      unless @notice.save
        render :new, locals: { model: @notice }, status: :unprocessable_entity
      end
    end

    private
    def set_template
      @template = Template.find params[:template_id]
    end

    def set_notice
      @notice = @template.notices.find(params[:id])
    end

    def notice_params
      params.fetch(:notice, {}).permit(
        :notifiable_type,
        :code,
        mappings: {}
      )
    end

  end
end
