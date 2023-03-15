module Wechat
  class Panel::OrgansController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:name, :corpid)

      @organs = Org::Organ.roots.default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

  end
end
