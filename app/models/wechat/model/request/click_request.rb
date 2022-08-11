module Wechat
  module Model::Request::ClickRequest

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.body = self.event_key
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        Array(rule[:msg_type]).include?(msg_type) &&
          Array(rule[:event]).include?(event&.downcase) &&
          rule[:body].match?(self.body)
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

  end
end
