module Wechat
  class Admin::OrgansController < Admin::BaseController
    before_action :set_organ
    before_action :set_corp_users, only: [:edit, :update]

    def show
    end

    private
    def set_organ
      @organ = current_organ
    end

    def set_corp_users
      if RailsWechat.config.suite_id.present?
        @corp_users = CorpUser.where(suite_id: RailsWechat.config.suite_id, corp_id: @organ.corpid)
      else
        @corp_users = CorpUser.none
      end
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :corpid,
        :corp_user_id
      )
    end

  end
end
