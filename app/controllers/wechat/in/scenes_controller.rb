module Wechat
  class In::ScenesController < In::BaseController
    before_action :set_app
    before_action :set_scene, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params

      @scenes = @app.scenes.includes(:response, tag: :user_tags).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @scene = @app.scenes.build
    end

    def create
      @scene = @app.scenes.build(scene_params)

      unless @scene.save
        render :new, locals: { model: @scene }, status: :unprocessable_entity
      end
    end

    def sync
      r= @app.api.menu_create @app.menu
      render 'sync', locals: { notice: r.to_s }
    end

    private
    def set_scene
      @scene = @app.scenes.find(params[:id])
    end

    def scene_params
      p = params.fetch(:scene, {}).permit(
        :match_value,
        :expire_seconds
      )
      p.merge! default_form_params
    end

  end
end
