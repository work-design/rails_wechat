module Wechat::Helpers

  def wechat_raw_config_js(wechat_app_id: nil, debug: false, apis: [])
    if wechat_app_id
      app = WechatApp.valid.find(wechat_app_id)
    else
      app = WechatApp.default
    end
    api = app.api
    page_url = controller.request.original_url
    page_url.delete_suffix!('#')
    js_hash = api.jsapi_ticket.signature(page_url)
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

  def wechat_config_js(wechat_app_id: nil, debug: false, apis: [])
    config_js = wechat_raw_config_js(wechat_app_id: wechat_app_id, debug: debug, apis: apis)
    javascript_tag config_js, type: 'application/javascript', nonce: true
  end

end

ActiveSupport.on_load :action_view do
  include Wechat::Helpers
end
