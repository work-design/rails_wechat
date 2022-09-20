module Wechat
  class BaseController < BaseController
    include Controller::Application

    private
    def xxx(oauth_user)
      state_hash = Base64.urlsafe_decode64(params[:state]).split('#')

      if oauth_user.user
        login_by_account(oauth_user.account)
        Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.token)

        url_options = {
          host: state_hash[0],
          controller: state_hash[1],
          action: state_hash[2],
          disposable_token: oauth_user.account.once_token,
          **state_hash[4].to_s.split('&').map(&->(i){ i.split('=') }).to_h
        }
        url = url_for(**url_options)

        redirect_to url, allow_other_host: true
      else
        url_options = {}
        url_options.merge! params.except(:controller, :action, :id, :business, :namespace, :code, :state).permit!
        url_options.merge! host: state_hash[0]
        url = url_for(controller: 'auth/sign', action: 'bind', uid: oauth_user.uid, **url_options)

        redirect_to url, allow_other_host: true
      end
    end

  end
end
