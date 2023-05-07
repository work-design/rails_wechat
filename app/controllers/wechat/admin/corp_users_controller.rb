module Wechat
  class Admin::CorpUsersController < Admin::BaseController
    before_action :set_agent
    before_action :set_corp_user, only: [:show, :edit, :update, :destroy]

    def index
      @corp_users = @agent.corp_users.page(params[:page])
    end

    private
    def set_agent
      @agent = Agent.find params[:agent_id]
    end

    def set_corp_user
      @corp_user = @agent.corp_users.find params[:id]
    end

  end
end
