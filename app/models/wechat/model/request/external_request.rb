module Wechat
  module Model::Request::ExternalRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :sync_to_external
    end

    def set_body
      self.userid = raw_body['UserID']
      self.event = raw_body['Event']
      self.event_key = raw_body['ChangeType']
      self.body = raw_body['ExternalUserID']
    end

    def sync_to_external
      corp_user&.sync_external(self.body)
    end
  end
end
