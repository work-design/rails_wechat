module RailsWechat
  include ActiveSupport::Configurable
  bind_proc = ->(request) {
    Wechat::NewsReply.new(request.reply_params)
  }

  configure do |config|
    config.httpx = {
      ssl: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    }
    config.email_domain = 'mail.work.design'
    config.suite_id = ''
    config.rules = ActiveSupport::OrderedOptions.new
    config.rules.a = {
      msg_type: 'event',
      event: 'templatesendjobfinish',
      proc: ->(request) {
        r = Wechat::Notice.find_by(msg_id: request.raw_body['MsgID'])
        r.update status: request.raw_body['Status']
        Wechat::TextReply.new(value: 'SUCCESS')
      }
    }
    config.rules.b = { msg_type: 'event', event: 'click', body: 'bind', proc: bind_proc }
    config.rules.b1 = { msg_type: 'event', event: ['subscribe', 'scan'], body: /^invite_by_/, proc: bind_proc }
    config.rules.b2 = { msg_type: 'event', event: ['subscribe', 'scan'], body: /^invite_member_/, proc: bind_proc }
    config.rules.b3 = { msg_type: 'event', event: ['subscribe', 'scan'], proc: bind_proc }
    config.rules.c = { msg_type: 'text', body: '绑定', proc: bind_proc }
    config.rules.c0 = {
      msg_type: 'text',
      body: '退出',
      proc: ->(request) {
        Wechat::NewsReply.new(
          appid: request.appid,
          news_reply_items_attributes: [
            {
              title: '退出登录',
              description: '绑定信息',
              url: Rails.application.routes.url_for(controller: 'auth/sign', action: 'logout')
            }
          ]
        )
      }
    }
    config.rules.c1 = {
      msg_type: 'text',
      body: 'TESTCOMPONENT_MSG_TYPE_TEXT',
      proc: ->(request) {
        Wechat::TextReply.new(value: 'TESTCOMPONENT_MSG_TYPE_TEXT_callback')
      }
    }
    config.rules.c2 = {
      msg_type: 'text',
      body: /QUERY_AUTH_CODE:/,
      proc: ->(request) {
        auth = request.platform.auths.build
        auth.auth_code = request.body.delete_prefix 'QUERY_AUTH_CODE:'
        auth.request = request
        auth.testcase = true
        auth.save
        Wechat::SuccessReply.new
      }
    }
  end

end
