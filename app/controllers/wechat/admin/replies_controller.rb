module Wechat
  class Admin::RepliesController < Admin::BaseController
    before_action :set_app
    before_action :set_reply, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @replies = @app.replies.default_where(q_params).page(params[:page])
    end

    def new
      @reply = @app.replies.build
    end

    def create
      @reply = @app.replies.build(reply_params)

      unless @reply.save
        render :new, locals: { model: @reply }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @reply.assign_attributes(reply_params)

      unless @reply.save
        render :edit, locals: { model: @reply }, status: :unprocessable_entity
      end
    end

    def destroy
      @reply.destroy
    end

    private
    def set_reply
      @reply = @app.replies.find(params[:id])
    end

    def reply_params
      params.fetch(:reply, {}).permit(
        :type,
        :title,
        :description,
        :value,
        :media,
        news_reply_items_attributes: {}
      )
    end

  end
end
