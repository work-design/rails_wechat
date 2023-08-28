module Wechat
  class Panel::SuitesController < Panel::BaseController
    before_action :set_provider
    before_action :set_new_suite, only: [:new, :create]

    def index
      @suites = @provider.suites.order(id: :asc).page(params[:page])
    end

    private
    def set_new_suite
      @suite = @provider.suites.build(suite_params)
    end

    def suite_params
      params.fetch(:suite, {}).permit(
        :name,
        :suite_id,
        :secret,
        :token,
        :encoding_aes_key,
        :redirect_controller,
        :redirect_action
      )
    end

  end
end
