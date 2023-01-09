module Wechat
  class BaseController < BaseController
    include Controller::Application

    private
    def xxx(oauth_user)
      state_hash = urlsafe_decode64(params[:state])

      if oauth_user.user
        login_by_oauth_user(oauth_user)
        Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.id)

        url = url_for(disposable_token: oauth_user.auth_token, **state_hash)
        redirect_to url, allow_other_host: true
      else
        url_options = { host: state_hash[:host] }
        url_options.merge! params.except(:controller, :action, :id, :business, :namespace, :code, :state).permit!
        url = url_for(controller: 'auth/sign', action: 'bind', uid: oauth_user.uid, **url_options)

        redirect_to url, allow_other_host: true
      end
    end

  end
end
