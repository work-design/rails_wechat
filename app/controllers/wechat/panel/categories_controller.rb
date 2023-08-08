module Wechat
  class Panel::CategoriesController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:parent_id, 'name-like')

      if q_params.key? :parent_id
        @categories = Category.default_where(q_params).page(params[:page])
      else
        @categories = Category.roots.default_where(q_params).page(params[:page])
      end
    end

  end
end
