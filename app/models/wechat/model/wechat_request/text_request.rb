module Wechat
  module RailsWechat::WechatRequest::TextRequest

    def reply
      self.wechat_reply = reply_from_rule
      return if self.wechat_reply

      wechat_responses.find do |wr|
        if wr.scan_regexp(body)
          self.wechat_reply = wr.invoke_effect(self)
        end
      end

      self
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
