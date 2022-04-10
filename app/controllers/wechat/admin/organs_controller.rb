module Wechat
  class Admin::OrgansController < Admin::BaseController
    before_action :set_organ

    def show
    end

    private
    def set_organ
      @organ = current_organ
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :corp_id,
        :corp_user_id
      )
    end

  end
end
