module Wechat
  class BaseController < BaseController
    include Controller::Application

    private
    def xxx(oauth_user)
      state = Com::State.find(params[:state])

      oauth_user.generate_account! unless oauth_user.user
      login_by_oauth_user(oauth_user)

      Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.id)

      render 'state_visit', layout: 'raw', locals: { state: state, auth_token: current_authorized_token.id }
    end

  end
end
