module Wechat
  module ApplicationHelper

    def wechat_raw_config_js(debug: false, apis: [])
      page_url = controller.request.original_url
      page_url.delete_suffix!('#')
      js_hash = Wechat::Signature.signature(current_wechat_app.jsapi_ticket, page_url)
      logger.debug "\e[35m  Current page is: #{page_url}, Hash: #{js_hash.inspect}  \e[0m"

      <<-WECHAT_CONFIG_JS
  wx.config({
    debug: #{debug},
    appId: '#{current_wechat_app.appid}',
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
