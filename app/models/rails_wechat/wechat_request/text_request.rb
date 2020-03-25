module RailsWechat::WechatRequest::TextRequest
  extend ActiveSupport::Concern

  def reply
    r = reply_from_rule
    return r if r

    res = wechat_responses.map do |wr|
      next unless wr.scan_regexp(body)

      wr.invoke_effect(self)
    end.compact

    if res.present?
      res.join("\n")
    else
      wechat_app.help
    end
  end

end
