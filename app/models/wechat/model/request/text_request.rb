module Wechat
  module Model::Request::TextRequest

    def reply_from_response
      responses.find do |wr|
        if wr.scan_regexp(body)
          wr.invoke_effect(self)
        end
      end
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        if rule[:msg_type] == 'text' && rule[:body]
          rule[:body].match? self.body
        end
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

  end
end
