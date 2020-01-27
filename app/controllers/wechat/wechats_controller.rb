class Wechat::WechatsController < ApplicationController
  include Wechat::Responder

  on :text, with: '绑定' do |received|
    reply_params = {
      wechat_user_id: received.wechat_user.id,
      news_reply_items_attributes: [
        {
          title: '请绑定',
          description: '绑定信息',
          url: _routes.url_helpers.bind_my_oauth_users_url(uid: received.wechat_user.uid)
        }
      ]
    }

    received.reply.with NewsReply.new(reply_params)
  end

  on :text do |received, content|
    wechat_request = received.wechat_user.wechat_requests.create(wechat_app_id: received.app.id, body: content, type: 'TextRequest')
    received.reply.by wechat_request
  end

  on :event, event: 'subscribe' do |received|
    wechat_request = received.wechat_user.wechat_requests.create(wechat_app_id: received.app.id, body: received[:EventKey], type: 'SubscribeRequest')
    received.reply.by wechat_request
  end

  on :event, event: 'unsubscribe' do |received|

  end

  on :event, event: 'scan' do |received|
    received.reply.with TextReply.new(wechat_user_id: received.wechat_user.id, content: received.qr_response)
  end

  on :event, event: 'click', with: 'bind' do |received|
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
