module Wechat
  class Admin::AgentsController < Admin::BaseController
    before_action :set_agent, only: [
      :show, :edit, :update, :destroy, :actions,
      :info, :edit_confirm, :update_confirm
    ]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :type, :agentid)

      @agents = Agent.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @agent = Agent.new
    end

    def create
      @agent = Agent.find_or_initialize_by(agentid: agent_params[:agentid])
      if @agent.organ
        @agent.errors.add :base, '该账号已在其他组织添加，请联系客服'
      end
      @agent.assign_attributes agent_params

      unless @agent.save
        render :new, locals: { model: @agent }, status: :unprocessable_entity
      end
    end

    def info
    end

    def edit_confirm
    end

    def update_confirm
      @agent.confirm_name = params[:confirm_file].original_filename
      @agent.confirm_content = params[:confirm_file].read if params[:confirm_file].respond_to?(:read)
      @agent.save
    end

    private
    def set_agent
      @agent = Agent.default_where(default_params).find(params[:id])
    end

    def set_new_agent
      @agent = Agent.new(agent_params)
    end

    def agent_params
      p = params.fetch(:agent, {}).permit(
        :name,
        :corpid,
        :secret,
        :agentid,
        :domain
      )
      p.merge! default_form_params
    end

  end
end
