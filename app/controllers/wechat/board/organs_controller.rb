module Wechat
  class Board::OrgansController < Wechat::BaseController
    before_action :set_organ, only: [:show, :edit, :update, :destroy]
    before_action :set_new_organ, only: [:new, :create]

    def index
      @organs = current_account.organs.includes(:organ_domains)

      if @organs.blank?
        @member = current_account.members.build
        @organ = @member.build_organ
        render :new
      else
        render 'index'
      end
    end

    def new
      @organ.who_roles.build(role_id: params[:role_id]) if params[:role_id].present?
    end

    def create
      @member = @organ.members.build(owned: true)
      @member.account = current_account
    end

    private
    def set_organ
      @organ = current_user.organs.find(params[:id])
    end

    def set_new_organ
      @organ = Organ.new(organ_params)
    end

    def member_params
      p = params.fetch(:member, {}).permit(
        :identity
      )
      p.merge! owned: true
      unless p[:identity]
        p.merge! identity: current_account.identity
      end
      p
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :name,
        :logo,
        who_roles_attributes: {}
      )
    end

  end
end
