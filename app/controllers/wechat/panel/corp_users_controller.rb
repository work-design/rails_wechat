module Wechat
  class Panel::CorpUsersController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp

    def index
      @corp_users = @corp.corp_users.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find_by corp_id: params[:provider_id]
    end

    def set_suite
      @suite = Suite.find params[:suite_id]
    end

    def set_corp
      @corp = Corp.find params[:corp_id]
    end

  end
end
