module Wechat
  class Panel::OrgansController < Panel::BaseController
    before_action :set_organ, only: [:edit]

    def index
      q_params = {}
      q_params.merge! params.permit(:name, :corpid)

      @organs = Organ.roots.default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

    private
    def set_organ
      @organ = Organ.find params[:id]
    end

  end
end
