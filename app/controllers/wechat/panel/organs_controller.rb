module Wechat
  class Panel::OrgansController < Panel::BaseController
    before_action :set_organ, only: [:edit, :update]
    before_action :set_apps, only: [:edit, :update]

    def index
      @organs = Org::Organ.where.associated(:apps).page(params[:page])
    end

    private
    def set_organ
      @organ = Org::Organ.find params[:id]
    end

    def set_apps
      q_params = {
        type: ['Wechat::PublicApp', 'Wechat::PublicAgency']
      }
      q_params.merge! organ_id: @organ.self_and_ancestor_ids

      @apps = App.default_where(q_params)
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :appid
      )
    end

  end
end
