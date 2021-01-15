module Wechat
  module Helpers

    def wechat_raw_config_js(debug: false, apis: [])
      app = current_wechat_app
      page_url = controller.request.original_url
      page_url.delete_suffix!('#')
      js_hash = Wechat::Signature.signature(app.jsapi_ticket, page_url)
      logger.debug "  ==========> Current page is: #{page_url}"
      logger.debug "  ==========> Hash: #{js_hash.inspect}"

      <<-WECHAT_CONFIG_JS
  wx.config({
    debug: #{debug},
    appId: '#{app.appid}',
    timestamp: '#{js_hash[:timestamp]}',
    nonceStr: '#{js_hash[:noncestr]}',
    signature: '#{js_hash[:signature]}',
    jsApiList: ['#{apis.join("','")}']
  })
  WECHAT_CONFIG_JS
    rescue => e
      logger.debug e.message
    end

    def wechat_config_js(debug: false, apis: [])
      config_js = wechat_raw_config_js(debug: debug, apis: apis)
      javascript_tag config_js, type: 'application/javascript', nonce: true
    end

  end
end

ActiveSupport.on_load :action_view do
  include Wechat::Helpers
end
