module RailsWechat::WechatRequest::SubscribeRequest
  extend ActiveSupport::Concern
  included do
  end

  def response
    result_msg = [
      {
        title: '欢迎关注',
        description: '查看数据'
      }]

    if body.present?
      qr_response
    else
      result_msg
    end
  end

  def qr_response
    key = body.delete_prefix('qrscene_')
    res = wechat_app.wechat_responses.where(request_type: type).find_by(match_value: key)
    res.invoke_effect(wechat_user) if res
  end

end

