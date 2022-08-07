module Wechat
  module Model::Request::ScanRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag, unless: -> { body.to_s.start_with?('session_') }
      after_create_commit :login_user, if: -> { body.to_s.start_with?('session_') }
    end

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = self.event_key
    end

    def login_user
      session_str, url = body.split('@')
      session = session_str.delete_prefix!('session_')
      url_options = URI(url)
      url = Rails.application.routes.url_for(
        controller: '/auth/sign',
        action: 'sign',
        uid: wechat_user.uid,
        host: url_options.host,
        protocol: url_options.scheme,
        port: url_options.port
      )

      auth_token = wechat_user.authorized_tokens.valid.first || wechat_user.account&.authorized_tokens&.valid&.first
      if auth_token
        Com::SessionChannel.broadcast_to session, auth_token: auth_token.token
      else
        Com::SessionChannel.broadcast_to session, url: url
      end
    end

  end
end
