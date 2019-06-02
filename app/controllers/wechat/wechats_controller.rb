class Wechat::WechatsController < ApplicationController
  include Wechat::Responder
  
  on :text do |received, content|
    set_wechat_user(received)
    
    if @wechat_user.user.nil?
      msg = @wechat_config.help_without_user
    elsif @wechat_user.user.disabled?
      msg = @wechat_config.help_user_disabled
    elsif content.match? Regexp.new(@wechat_config.match_values)
      wf = @wechat_user.wechat_feedbacks.create(wechat_config_id: @wechat_config.id, body: content)
      res = @wechat_config.text_responses.map do |wr|
        if content.match?(Regexp.new(wr.match_value))
          if wr.effective?
            ri = wf.response_items.create(wechat_response_id: wr.id)
            ri.respond_text
          else
            wr.invalid_response.presence
          end
        end
      end.compact
      
      msg = "#{@wechat_config.help_feedback}#{res.join(', ')}"
    else
      msg = @wechat_config.help
    end

    received.reply.text msg
  end
  
  on :text, with: '注册' do |received, content|
    @wechat_user = set_wechat_user(message)
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: sign_url(uid: @wechat_user.uid)
      }
    ]

    received.reply.news result_msg
  end

  on :event, with: 'subscribe' do |message, content|
    result_msg = [{
      title: '欢迎关注',
      description: '查看数据'
    }]

    if message[:EventKey]
      message.reply.text get_response(message)
    else
      message.reply.news(result_msg)
    end
  end

  on :event, event: 'SCAN' do |message|
    message.reply.text get_response(message)
  end

  on :event, event: 'click', with: 'join' do |message, key|
    @wechat_user = set_wechat_user(message)
  
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: sign_url(uid: @wechat_user.uid)
      }
    ]
    
    message.reply.news result_msg
  end
  
  private
  def get_response(message)
    set_wechat_user(message)
    key = message[:EventKey].to_s.delete_prefix('qrscene_')
    res = @wechat_config.scan_responses.find_by(match_value: key)
    res.invoke_effect(@wechat_user)
  end
  
  def set_wechat_user(message)
    @wechat_user = WechatUser.find_or_initialize_by(uid: message[:FromUserName])
    @wechat_user.app_id = @wechat_config.appid
    @wechat_user.save
    @wechat_user
  end
  
end
