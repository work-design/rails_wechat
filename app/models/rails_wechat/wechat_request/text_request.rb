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

end
