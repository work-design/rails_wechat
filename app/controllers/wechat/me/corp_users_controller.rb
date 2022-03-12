module Wechat
  class Me::CorpUsersController < Me::BaseController
    before_action :set_corp_user, only: [:show]

    def show
    end

    private
    def set_corp_user
      persist_corp_user
      @corp_user = current_corp_user
    end

    def persist_corp_user
      @corp_user = current_account.corp_users.where(suite_id: params[:suite_id])
      current_authorized_token.update corp_user_id: @corp_user.id
    end

  end
end
