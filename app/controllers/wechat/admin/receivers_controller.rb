module Wechat
  class Admin::ReceiversController < Admin::BaseController
    before_action :set_app
    before_action :set_payee
    before_action :set_receiver, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_receiver, only: [:new, :new_openid, :create]

    def users
      q_params = {}
      q_params.merge! params.permit('user_tags.tag_name', :name, :uid)

      @wechat_users = @app.wechat_users.includes(:account, :user, :user_tags).default_where(q_params).order(id: :desc).page(params[:page])

      @select_uids = @payee.receivers.where(account: @wechat_users.pluck(:uid)).pluck(:account)
    end

    def new_openid
    end

    def destroy_openid
      @receiver = @payee.receivers.find_by account: params[:uid]
      @receiver.destroy
    end

    private
    def set_app
      @app = App.find_by appid: params[:app_id]
    end

    def set_payee
      @payee = @app.payees.find params[:payee_id]
    end

    def set_receiver
      @receiver = @payee.receivers.find params[:id]
    end

    def set_new_receiver
      @receiver = @payee.receivers.build(receiver_params)
    end

    def receiver_params
      params.fetch(:receiver, {}).permit(
        :name,
        :account,
        :receiver_type,
        :relation_type,
        :custom_relation
      )
    end
  end
end
