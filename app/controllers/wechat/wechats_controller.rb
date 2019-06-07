class Wechat::WechatsController < ApplicationController
  include Wechat::Responder

  on :text, with: '注册' do |received|
    wechat_user = get_wechat_user(received)
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: url_helpers.sign_url(uid: wechat_user.uid)
      }
    ]
  
    received.reply.news result_msg
  end

  on :text do |received, content|
    wechat_user = get_wechat_user(received)
    
    if wechat_user.user.nil?
      msg = received.app.help_without_user
    elsif wechat_user.user.disabled?
      msg = received.app.help_user_disabled
    elsif content.match? Regexp.new(received.app.match_values)
      wf = wechat_user.wechat_feedbacks.create(wechat_config_id: received.app.id, body: content)
      res = received.app.text_responses.map do |wr|
        if content.match?(Regexp.new(wr.match_value))
          if wr.effective?
            ri = wf.response_items.create(wechat_response_id: wr.id)
            ri.respond_text
          else
            wr.invalid_response.presence
          end
        end
      end.compact
      
      msg = "#{received.app.help_feedback}#{res.join(', ')}"
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
      received.reply.text get_response(received)
    else
      received.reply.news(result_msg)
    end
  end

  on :event, event: 'scan' do |received|
    received.reply.text get_response(received)
  end

  on :event, event: 'click', with: 'join' do |received|
    wechat_user = get_wechat_user(received)
  
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: url_helpers.sign_url(uid: wechat_user.uid)
      }
    ]
    
    received.reply.news result_msg
  end
  
  private
  def self.get_response(received)
    wechat_user = get_wechat_user(received)
    key = received[:EventKey].to_s.delete_prefix('qrscene_')
    res = received.app.scan_responses.find_by(match_value: key)
    res.invoke_effect(wechat_user)
  end
  
  def self.get_wechat_user(received)
    wechat_user = WechatUser.find_or_initialize_by(uid: received[:FromUserName])
    wechat_user.app_id = received.app.appid
    wechat_user.save
    wechat_user
  end
  
end
