class Wechat::WechatsController < ApplicationController
  wechat_responder account_from_request: Proc.new{ |request| request.params[:id] }
  before_action :set_wechat_config, only: [:create]
  
  on :text do |request, content|
    set_wechat_user(request)
    
    if @wechat_user.user.nil? || @wechat_user.user.disabled?
      msg = '你没有权限！'
    elsif content.match? /施工作业C票|配电一种票|低压停电票/
      piao = []
      if content.match? /施工作业C票/
        r = @wechat_user.wechat_feedbacks.create(wechat_config_id: @wechat_config.id, body: content, kind: 'kind_a')
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
      msg = "请按标准模板填写！\n"
      msg << "项目名称：xxx。\n工作内容：xxx。\n计划工作时间：xx月xx日xx时xx分-xx月xx日xx时xx分\n申请施工作业C票号1份，配电一种票号1份，低压停电票号1份。"
    end
    
    request.reply.text msg
  end
  
  on :text, with: '注册' do |request, content|
    @wechat_user = set_wechat_user(request)
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
    @wechat_user = set_wechat_user(request)
  
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(oauth_user_id: @wechat_user.id)
      }
    ]
    
    request.reply.news result_msg
  end
  
  private
  def set_wechat_config
    @wechat_config = WechatConfig.find_by account: params[:id]
  end
  
  def set_wechat_user(request)
    @wechat_user = WechatUser.find_or_initialize_by(uid: request[:FromUserName])
    @wechat_user.app_id = @wechat_config.appid
    @wechat_user.save
    @wechat_user
  end
  
end
