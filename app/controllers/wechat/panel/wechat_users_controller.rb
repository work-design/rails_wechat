module Wechat
  class Panel::WechatUsersController < Panel::BaseController
    before_action :set_app
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy, :actions, :chat, :message]
    before_action :set_tag, only: [:index]
    before_action :set_tags, only: [:index]

    def index
      q_params = {}
      q_params.merge! params.permit('user_tags.tag_name', :scene_tag, :name, :uid, :user_inviter_id)

      @wechat_users = @app.wechat_users.includes(:account, :user, :user_tags).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def edit
      @tags = @app.tags
    end

    def chat
      @messages = @wechat_user.messages.order(id: :desc).page(params[:page]).per(10)
    end

    def message
      @message_send = @wechat_user.msg_send(params[:content])
    end

    private
    def set_wechat_user
      @wechat_user = @app.wechat_users.find params[:id]
    end

    def set_tag
      if params['user_tags.tag_name']
        @tag = @app.tags.find_by name: params['user_tags.tag_name']
      end
    end

    def set_tags
      @tags = @app.tags.where(kind: 'normal')
    end

    def wechat_user_params
      params.fetch(:wechat_user, {}).permit(
        :name,
        :remark,
        :auto_reply,
        tag_ids: []
      )
    end

  end
end
