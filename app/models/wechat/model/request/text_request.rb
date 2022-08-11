module Wechat
  module Model::Request::TextRequest

    def set_body
      self.body = raw_body['Content']
    end

    def reply_from_response
      res = responses.find(&->(r){ r.scan_regexp(body) })
      res.invoke_effect(self) if res
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        Array(rule[:msg_type]).include?('text') && rule[:body] && rule[:body].match?(self.body)
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

  end
end
