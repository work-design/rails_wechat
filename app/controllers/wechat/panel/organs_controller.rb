module Wechat
  class Panel::OrgansController < Panel::BaseController
    before_action :set_organ, only: [:edit, :update]

    def index
      q_params = {}
      q_params.merge! params.permit(:name, :corpid)

      @organs = Org::Organ.roots.default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

    private
    def set_organ
      @organ = Org::Organ.find params[:id]
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :corpid
      )
    end
  end
end
