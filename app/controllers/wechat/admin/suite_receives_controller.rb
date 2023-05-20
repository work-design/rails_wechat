module Wechat
  class Admin::SuiteReceivesController < Admin::BaseController
    before_action :set_agent

    def index
      q_params = {}
      q_params.merge! params.permit(:info_type, :corpid)

      @suite_receives = @agent.suite_receives.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_agent
      @agent = Agent.find params[:agent_id]
    end

  end
end
