module WechatRequestExtend
  extend ActiveSupport::Concern

  included do

    bind_proc = Proc.new do |request|
      reply_params = {
        wechat_user_id: request.wechat_user.id,
        news_reply_items_attributes: [
          {
            title: '请绑定',
            description: '绑定信息',
            url: url_helpers.bind_my_oauth_users_url(uid: request.wechat_user.uid, subdomain: request.wechat_app&.organ&.subdomain)
          }
        ]
      }

      NewsReply.new(reply_params)
    end
    on msg_type: 'text' do |request|
      if request.wechat_user.user.nil?
        value = '请绑定账号，输入"绑定"根据提示操作'
      elsif wechat_user.user.disabled?
        value = '你的账号已被禁用'
      else
        value = ''
      end
      TextReply.new value: value
    end
    on msg_type: 'event', event: 'click', body: 'bind', proc: bind_proc
    on msg_type: 'text', body: '绑定', proc: bind_proc
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
