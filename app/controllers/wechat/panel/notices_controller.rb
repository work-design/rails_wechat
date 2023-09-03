module Wechat
  class Panel::NoticesController < Panel::BaseController
    before_action :set_template
    before_action :set_notice, only: [:show, :edit, :update, :destroy]

    def index
      @notices = @template.notices.order(id: :desc).page(params[:page])
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
