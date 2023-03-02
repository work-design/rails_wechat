module Wechat
  class BaseController < BaseController
    include Controller::Application

    private
    def xxx(oauth_user)
      state_hash = urlsafe_decode64(params[:state])

      oauth_user.generate_account! unless oauth_user.user
      login_by_oauth_user(oauth_user)

      Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.id)
      url = url_for(auth_token: current_authorized_token.id, **state_hash.except(:auth_token))
      redirect_to url, allow_other_host: true
    end

  end
end
