module Wechat
  module Model::Request::ScanRequest
    extend ActiveSupport::Concern

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
