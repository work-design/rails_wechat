module Wechat
  class Panel::PayeesController < Panel::BaseController

    def index
      @payees = Payee.includes(:organ).page(params[:page])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
    end

    private
    def set_payee
      @payee = Payee.find params[:id]
    end

  end
end
