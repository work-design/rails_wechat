module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag, unless: -> { body.to_s.start_with?('session_') }
      after_create_commit :login_user, if: -> { body.to_s.start_with?('session_') }
    end

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = event_key.delete_prefix('qrscene_')
    end

  end
end
