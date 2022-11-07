module Wechat
  class Panel::MaintainsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp

    def index
      q_params = {}
      q_params.merge! organ_id: @corp.organ&.id
      q_params.merge! params.permit(:state, :userid)

      @maintains = Crm::Maintain.default_where(q_params).page(params[:page])
    end

  end
end
