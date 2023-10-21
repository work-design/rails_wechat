module Wechat
  class Board::OrgansController < defined?(RailsOrg) ? Org::Board::OrgansController : Board::BaseController
    before_action :set_organ, only: [:show, :edit, :update, :destroy]
    before_action :set_corp, only: [:new, :index]
    before_action :set_new_organ, only: [:new, :create]

    def index
      @organs = current_account.organs.includes(:organ_domains)

      if @organs.blank?
        set_new_organ
        render :new
      else
        render 'index'
      end
    end

    private
    def set_corp
      @corp = Corp.find params[:corpid] if params[:corp_id]
    end

    def set_organ
      @organ = current_user.organs.find(params[:id])
    end

    def set_new_organ
      @member = current_account.members.build(owned: true)
      @organ = @member.build_organ(corpid: @corp&.corpid, **organ_params)
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :name,
        :logo,
        :corpid,
        who_roles_attributes: {}
      )
    end

  end
end
