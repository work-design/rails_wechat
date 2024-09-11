module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      after_save_commit :sync_to_wechat_user
    end

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = event_key.delete_prefix('qrscene_')
    end

    def sync_to_wechat_user
      wechat_user.update unsubscribe_at: nil
    end

  end
end
