module RailsWechat::WechatRequest::SubscribeRequest
  extend ActiveSupport::Concern

  def response
    if body.present?
      qr_response
    else
      r = wechat_app.wechat_responses.where(request_type: type).map do |wr|
        if wr.effective.is_a? WechatReply
          wr.effective
        else
          wr.invoke_effect(self)
        end
      end
      r[0]
    end
  end

  def qr_response
    key = body.delete_prefix('qrscene_')
    res = wechat_app.wechat_responses.where(request_type: type).find_by(match_value: key)
    res.invoke_effect(wechat_user) if res
  end

end

