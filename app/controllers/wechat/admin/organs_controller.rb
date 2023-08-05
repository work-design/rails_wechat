module Wechat
  class Admin::OrgansController < Admin::BaseController
    before_action :set_organ
    before_action :set_apps, only: [:edit, :update]
    before_action :set_agencies, only: [:edit, :update]

    def show
    end

    private
    def set_organ
      @organ = current_organ
    end

    def set_apps
      q_params = {}
      q_params.merge! organ_id: current_organ.self_and_ancestor_ids

      @apps = PublicApp.default_where(q_params)
    end

    def set_agencies
      q_params = {}
      q_params.merge! organ_id: current_organ.self_and_ancestor_ids

      @agencies = PublicAgency.default_where(q_params)
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :appid
      )
    end

  end
end
