module RailsWechat::WechatRequest::SubscribeRequest
  extend ActiveSupport::Concern

  def reply
    if body.present?
      qr_response
    else
      r = wechat_responses.where(request_type: type).map do |wr|
        wr.invoke_effect(self)
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

