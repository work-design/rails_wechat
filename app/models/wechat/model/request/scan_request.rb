module Wechat
  module Model::Request::ScanRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag, if: -> { body.to_s.start_with?('auth_user_', 'org_member_') }
      after_create_commit :login_user, if: -> { body.to_s.start_with?('session_') }
    end

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = self.event_key
    end

    def reply_from_response
      r = super
      return r if r.present?

      Wechat::TextReply.new(value: '登录成功！') if body.to_s.start_with?('session_')
    end

  end
end
