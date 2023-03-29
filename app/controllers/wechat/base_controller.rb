module Wechat
  class BaseController < BaseController
    include Controller::Application

    private
    def xxx(oauth_user)
      state = Com::State.find_by(id: params[:state])

      oauth_user.generate_account! unless oauth_user.user
      state.update user_id: oauth_user.user&.id if state
      login_by_oauth_user(oauth_user)

      Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.id)

      response.headers['Access-Control-Allow-Origin'] = request.origin.presence || '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-Csrf-Token, X-User-Token, X-User-Email'
      response.headers['Access-Control-Max-Age'] = '1728000'
      response.headers['Access-Control-Allow-Credentials'] = true

      if state
        render 'state_visit', layout: 'raw', locals: { state: state, auth_token: current_authorized_token.id }
      else
        render 'visit', layout: 'raw', locals: { url: url_for(controller: '/home') }
      end
    end

  end
end
