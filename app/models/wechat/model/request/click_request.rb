module Wechat
  module Model::Request::ClickRequest

    def rule_tag
      {
        msg_type: msg_type,
        event: event&.downcase,
        body: body
      }.compact
    end

    def set_body
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.event = raw_body['Event']
      self.body = self.event_key
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        rule.slice(:msg_type, :event, :body) == self.rule_tag
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

  end
end
