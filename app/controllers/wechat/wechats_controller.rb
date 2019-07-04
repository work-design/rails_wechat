class Wechat::WechatsController < ApplicationController
  include Wechat::Responder

  on :text, with: '绑定' do |received|
    result_msg = [
      {
        title: '请绑定',
        description: '绑定信息',
        url: _routes.url_helpers.bind_my_oauth_users_url(uid: received.wechat_user.uid)
      }
    ]
  
    received.reply.news result_msg
  end

  on :text do |received, content|
    if received.wechat_user.user.nil?
      msg = received.app.help_without_user
    elsif received.wechat_user.user.disabled?
      msg = received.app.help_user_disabled
    elsif 'accept_not_match_feedback'
      wf = received.wechat_user.wechat_requests.create(wechat_app_id: received.app.id, body: content, type: 'TextRequest')
      msg = wf.response
    else
      msg = received.app.help
    end

    received.reply.text msg
  end
 
  on :event, event: 'subscribe' do |received|
    result_msg = [{
      title: '欢迎关注',
      description: '查看数据'
    }]

    if received[:EventKey]
      received.reply.text received.qr_response
    else
      received.reply.news(result_msg)
    end
  end

  on :event, event: 'scan' do |received|
    received.reply.text received.qr_response
  end

  on :event, event: 'click', with: 'bind' do |received|
    result_msg = [
      {
        title: '请绑定',
        description: '绑定信息',
        url: _routes.url_helpers.bind_my_oauth_users_url(uid: received.wechat_user.uid)
      }
    ]
    
    received.reply.news result_msg
  end
  
end
