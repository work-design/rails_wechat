class Wechat::WechatsController < ApplicationController
  wechat_responder account_from_request: Proc.new{ |request| request.params[:id] }

  on :text do |request, content|
    request.reply.text "echo: #{content}" # Just echo
  end

  on :text, with: '工作计划' do |request, content|
    @wechat_user = WechatUser.find_or_create_by(uid: request[:FromUserName])
    r = @wechat_user.wechat_feedbacks.create(body: content)
    request.reply.text "工作计划提交成功，你的票号为： #{r.position}"
  end
  
  on :text, with: '注册' do |request, content|
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(uid: request[:FromUserName])
      }
    ]
  
    request.reply.news result_msg
  end

  on :event, with: 'subscribe' do |request, content|
    result_msg = [{
      title: '欢迎关注',
      description: '查看数据'
    }]

    if request[:EventKey] == 'qrscene_1'
      request.reply.text '签到成功'
    else
      request.reply.news(result_msg)
    end
  end

  on :event, with: 'scan' do |request|
    if request[:EventKey] == '1'
      request.reply.text '签到成功'
    end
  end

  on :click, with: 'join' do |request, key|
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(uid: request[:FromUserName])
      }
    ]
    
    request.reply.news result_msg
  end
  
  def init_wechat_user(request)
    wechat_user = WechatUser.find_or_create_by(uid: request[:FromUserName])
  end
  
end
