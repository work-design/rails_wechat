module Wechat
  class Panel::MaintainsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp
    before_action :set_maintain, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! organ_id: @corp.organ_id
      q_params.merge! params.permit(:state, :userid)

      @maintains = Crm::Maintain.where(q_params).page(params[:page])
    end

    private
    def set_maintain
      @maintain = Crm::Maintain.find params[:id]
    end

  end
end
