module Wechat
  class In::AppsController < In::BaseController
    before_action :set_app, only: [:show]

    def index
      q_params = {
        organ_id: current_organ.self_and_ancestor_ids.append(current_organ.provider_id)
      }
      q_params.merge! params.permit(:id)

      @apps = App.default_where(q_params).order(id: :asc).page(params[:page])
    end

  end
end
