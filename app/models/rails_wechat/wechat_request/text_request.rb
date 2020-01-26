module RailsWechat::WechatRequest::TextRequest
  extend ActiveSupport::Concern

  def response
    res = wechat_app.text_responses.map do |wr|
      if wr.scan_regexp(body)
        wr.invoke_effect(self)
      end
    end.compact

    if res.present?
      res.join("\n")
    else
      wechat_app.help
    end
  end

end
