module RailsWechat
  include ActiveSupport::Configurable
  bind_proc = ->(request) {
    reply_params = {
      appid: request.appid,
      news_reply_items_attributes: [
        {
          title: '请绑定',
          description: '绑定信息',
          url: request.bind_url
        }
      ]
    }

    Wechat::NewsReply.new(reply_params)
  }

  configure do |config|
    config.httpx = {
      ssl: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    }
    config.email_domain = 'mail.work.design'
    config.rules = ActiveSupport::OrderedOptions.new
    config.rules.xx = {
      msg_type: 'text',
      proc: ->(request) {
        if request.wechat_user.user.nil?
          value = '请绑定账号，输入"绑定"根据提示操作'
        elsif wechat_user.user.disabled?
          value = '你的账号已被禁用'
        else
          value = ''
        end
        Wechat::TextReply.new value: value
      }
    }
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
    config.rules.c = { msg_type: 'text', body: '绑定', proc: bind_proc }
    config.rules.d = {
      msg_type: 'text',
      body: '退出',
      proc: ->(request) {
        reply_params = {
          appid: request.appid,
          news_reply_items_attributes: [
            {
              title: '退出登录',
              description: '绑定信息',
              url: request.url_helpers.logout_url
            }
          ]
        }

        Wechat::NewsReply.new(reply_params)
      }
    }
    config.rules.e = {
      msg_type: 'text',
      body: 'TESTCOMPONENT_MSG_TYPE_TEXT',
      proc: ->(request) {
        Wechat::TextReply.new(value: 'TESTCOMPONENT_MSG_TYPE_TEXT_callback')
      }
    }
    config.rules.f = {
      msg_type: 'text',
      body: /QUERY_AUTH_CODE:/,
      proc: ->(request) {
        wechat_auth = request.platform.wechat_auths.build
        wechat_auth.auth_code = request.body.delete_prefix 'QUERY_AUTH_CODE:'
        wechat_auth.request = request
        wechat_auth.testcase = true
        wechat_auth.save
        Wechat::SuccessReply.new
      }
    }
  end

end
