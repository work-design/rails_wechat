module WechatRequestExtend
  extend ActiveSupport::Concern
  included do

    #msg_type: 'event', event: 'click', body: 'bind'
    on msg_type: 'text', body: '绑定' do |request|
      reply_params = {
        wechat_user_id: request.wechat_user_id,
        news_reply_items_attributes: [
          {
            title: '请绑定',
            description: '绑定信息',
            url: url_helpers.bind_my_oauth_users_url(uid: request.wechat_user.uid, organ_id: request.wechat_app.organ_id)
          }
        ]
      }

      NewsReply.new(reply_params)
    end

    on msg_type: 'event', event: 'templatesendjobfinish' do |request|
      r = WechatNotice.find_by(msg_id: request.raw_body['MsgID'])
      r.update status: request.raw_body['Status']

      TextReply.new(wechat_user_id: request.wechat_user_id, value: 'SUCCESS')
    end

  end

  class_methods do

    def url_helpers
      Rails.application.routes.url_helpers
    end

  end

end
