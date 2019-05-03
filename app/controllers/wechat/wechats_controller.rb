class Wechat::WechatsController < ApplicationController
  wechat_responder account_from_request: Proc.new{ |request| request.params[:id] }

  on :text do |request, content|
    @wechat_user = WechatUser.init_wechat_user(request)
  
    if content.match? /施工作业C票|配电一种票|低压停电票/
      piao = []
      if content.match? /施工作业C票/
        r = @wechat_user.wechat_feedbacks.create(body: content, kind: 'kind_a')
        piao << "施工作业C票：#{r.number_str}"
      end
      
      if content.match? /配电一种票/
        r = @wechat_user.wechat_feedbacks.create(body: content, kind: 'kind_b')
        piao << "配电一种票：#{r.number_str}"
      end
      
      if content.match? /低压停电票/
        r = @wechat_user.wechat_feedbacks.create(body: content, kind: 'kind_c')
        piao << "低压停电票：#{r.number_str}"
      end
      
      msg = "工作计划提交成功，你的票号为： #{piao.join(', ')}"
    else
      msg = '请按标准模板填写！'
    end
    
    request.reply.text msg
  end
  
  on :text, with: '帮助' do |request, content|
    msg = "项目名称：10kv台子线擂鼓台7号改造。\n工作内容：电杆组立，金具组装，导线展放。\n计划工作时间：5月4日 08.00分-5月4日19.00分\n申请施工作业C票号 1份，配电一种票号  1份，低压停电票号  1份。"
    request.reply.text msg
  end
  
  on :text, with: '注册' do |request, content|
    @wechat_user = WechatUser.init_wechat_user(request)
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(oauth_user_id: @wechat_user.id)
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
    @wechat_user = WechatUser.init_wechat_user(request)
  
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(oauth_user_id: @wechat_user.id)
      }
    ]
    
    request.reply.news result_msg
  end
  
end
