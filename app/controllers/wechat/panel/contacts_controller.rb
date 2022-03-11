module Wechat
  class Panel::ContactsController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:user_id, :corp_id)

      @contacts = Contact.default_where(q_params).page(params[:page])
    end

  end
end
