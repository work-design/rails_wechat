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
      r = body.delete_prefix!('session_')
      auth_token = wechat_user.authorized_tokens.valid.first || wechat_user.account&.authorized_tokens&.valid&.first
      Com::SessionChannel.broadcast_to(r, auth_token: auth_token.token) if r && auth_token
    end

  end
end
