class Wechat::WechatsController < ApplicationController
  wechat_responder account_from_request: Proc.new{ |request| request.params[:id] }
  before_action :set_wechat_config, only: [:create]
  
  on :text do |request, content|
    set_wechat_user(request)
    
    if @wechat_user.user.nil? || @wechat_user.user.disabled?
      msg = '你没有权限！'
    elsif content.match? Regexp.new(@wechat_config.regexps)
      piao = []
      @wechat_config.wechat_responses.each do |wr|
        if content.match? Regexp.new(wr.regexp)
          r = @wechat_user.wechat_feedbacks.create(wechat_config_id: @wechat_config.id, body: content, kind: wr.regexp)
          piao << "#{wr.regexp}：#{r.number_str}"
        end
      end
      
      msg = "工作计划提交成功，你的票号为： #{piao.join(', ')}"
    else
      msg = @wechat_config.help
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
