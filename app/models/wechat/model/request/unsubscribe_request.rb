module Wechat
  module Model::Request::UnsubscribeRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :sync_to_wechat_user
    end

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = self.event_key
    end

    def sync_to_wechat_user
      wechat_user.update unsubscribe_at: Time.current
    end
  end
end
