module WechatRequestExtend
  extend ActiveSupport::Concern
  included do

    on msg_type: 'text', body: '绑定' do |received|
      reply_params = {
        wechat_user_id: received.wechat_user.id,
        news_reply_items_attributes: [
          {
            title: '请绑定',
            description: '绑定信息',
            url: _routes.url_helpers.bind_my_oauth_users_url(uid: received.wechat_user.uid, organ_id: received.app.organ_id)
          }
        ]
      }

      received.reply.with NewsReply.new(reply_params)
    end

    on msg_type: 'event', event: 'templatesendjobfinish' do |received, content|
      r = WechatNotice.find_by(msg_id: content['MsgID'])
      r.update status: content['Status']
      received.reply.with TextReply.new(wechat_user_id: received.wechat_user.id, value: 'SUCCESS')
    end

    on msg_type: 'event', event: 'click', body: 'bind' do |received|
      reply_parms = {
        wechat_user_id: received.wechat_user.id,
        news_reply_items_attributes: [
          {
            title: '请绑定',
            description: '绑定信息',
            url: _routes.url_helpers.bind_my_oauth_users_url(uid: received.wechat_user.uid)
          }
        ]
      }

      received.reply.with NewsReply.new(reply_parms)
    end

  end

end
