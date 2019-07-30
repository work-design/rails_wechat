module Wechat
  module Helpers
    
    def wechat_raw_config_js(wechat_app_id: nil, debug: false, apis: [])
      app = Wechat.config(wechat_app_id)
      api = Wechat.api(wechat_app_id)
      page_url = controller.request.original_url
      page_url.delete_suffix!('#')
      
      js_hash = api.jsapi_ticket.signature(page_url)

      <<-WECHAT_CONFIG_JS
wx.config({
  debug: #{debug},
  appId: '#{app.appid}',
  timestamp: '#{js_hash[:timestamp]}',
  nonceStr: '#{js_hash[:noncestr]}',
  signature: '#{js_hash[:signature]}',
  jsApiList: ['#{apis.join("','")}']
});
WECHAT_CONFIG_JS
    rescue
      
    end

    def wechat_config_js(wechat_app_id: nil, debug: false, apis: [])
      config_js = wechat_raw_config_js(wechat_app_id: wechat_app_id, debug: debug, apis: apis)
      javascript_tag config_js, type: 'application/javascript'
    end
    
  end
end

ActiveSupport.on_load :action_view do
  include Wechat::Helpers
end
