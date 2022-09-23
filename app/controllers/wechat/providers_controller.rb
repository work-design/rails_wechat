module Wechat
  class ProvidersController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_provider, only: [:login, :auth]

    def login
      @corp_user = @provider.generate_corp_user(params[:code])
      if session[:return_to].present?
        url = session[:return_to]
        session.delete :return_to
      else
        url = url_for(controller: '/my/home')
      end

      if @corp_user.save
        login_by_account(@corp_user.account)
        render :login, locals: { url: url }
      else
        render :login, locals: { url: url }
      end
    end

    # https://developer.work.weixin.qq.com/document/path/91125
    # 业务设置URL
    def auth
      @corp_user = @provider.init_by_auth_code(params[:auth_code])

      if @corp_user.save
        login_by_account(@corp_user.account)
        render :auth
      else
        render :auth
      end
    end

    private
    def ticket_params
      params.permit(
        :timestamp,
        :nonce,
        :msg_signature
      )
    end

    def set_provider
      @provider = Provider.find_by corp_id: params[:id]
    end

    def verify_signature
      if @provider
        # 消息体签名校验: https://open.work.weixin.qq.com/api/doc/90000/90139/90968#消息体签名校验
        dev_signature = Wechat::Signature.hexdigest(@provider.token, params[:timestamp], params[:nonce], params[:echostr])
        forbidden = (params[:msg_signature] != dev_signature)
      else
        forbidden = true
      end

      render plain: 'Forbidden', status: 403 if forbidden
    end

  end
end
