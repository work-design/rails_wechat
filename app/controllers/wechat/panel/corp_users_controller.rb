module Wechat
  class Panel::CorpUsersController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp

    def index
      @corp_users = @corp.corp_users.page(params[:page])
    end

  end
end
