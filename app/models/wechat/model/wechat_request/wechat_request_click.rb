module Wechat
  module RailsWechat::WechatRequest::WechatRequestClick
    extend ActiveSupport::Concern

    included do
    end

    def rule_tag
      {
        msg_type: msg_type,
        event: event&.downcase,
        body: body
      }.compact
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        rule.slice(:msg_type, :event, :body) == self.rule_tag
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

  end
end
