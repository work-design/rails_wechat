module Wechat
  class Me::CorpUsersController < Me::BaseController
    before_action :set_corp_user, only: [:show]

    def show
    end

    private
    def set_corp_user
      @corp_user = current_corp_user
    end

  end
end
