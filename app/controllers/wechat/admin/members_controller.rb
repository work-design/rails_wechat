module Wechat
  class Admin::MembersController < Admin::BaseController
    before_action :set_member, only: [:show, :edit, :update]

    def index
      q_params = {
        enabled: true
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :identity, :organ_id, 'name-like', :enabled, :department_ancestors)
      @members = Org::Member.includes(:roles).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def wechat
      q_params = {}
      q_params.merge! default_params

      @members = Org::Member.includes(:roles).default_where(q_params).where.not(wechat_openid: nil).order(id: :desc).page(params[:page])
    end

    def corp
      q_params = {}
      q_params.merge! default_params

      @members = Org::Member.includes(:roles).default_where(q_params).where.not(corp_userid: nil).order(id: :desc).page(params[:page])
    end

    private
    def set_member
      @member = Org::Member.find(params[:id])
    end

    def member_params
      params.fetch(:member, {}).permit(
        :wechat_openid,
        :identity
      )
    end

  end
end
