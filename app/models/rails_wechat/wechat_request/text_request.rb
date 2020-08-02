module RailsWechat::WechatRequest::TextRequest

  def reply
    self.wechat_reply = reply_from_rule
    return if self.wechat_reply

    res = wechat_responses.map do |wr|
      next unless wr.scan_regexp(body)

      wr.invoke_effect(self)
    end.compact

    if res.present?
      res.join("\n")
    end
  end

end
