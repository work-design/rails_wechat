module Wechat
  class Panel::CategoriesController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit('name-like')

      @categories = Category.default_where(q_params).page(params[:page])
    end

  end
end
