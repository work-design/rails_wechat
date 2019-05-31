module Wechat
  module Helpers
    
    def wechat_raw_config_js(config_options = {})
      account = config_options[:account]
      
      app = Wechat.config(account)
      api = Wechat.api(account)

      if app.trusted_domain_fullname
        page_url = "#{app.trusted_domain_fullname}#{controller.request.original_fullpath}"
      else
        page_url = controller.request.original_url
      end
      page_url.delete_suffix!('#')
      
      js_hash = api.jsapi_ticket.signature(page_url)

      <<-WECHAT_CONFIG_JS
wx.config({
  debug: #{config_options[:debug]},
  appId: '#{app.appid}',
  timestamp: '#{js_hash[:timestamp]}',
  nonceStr: '#{js_hash[:noncestr]}',
  signature: '#{js_hash[:signature]}',
  jsApiList: ['#{config_options[:api].join("','")}']
});
WECHAT_CONFIG_JS
    end

    def wechat_config_js(config_options = {})
      config_js = wechat_raw_config_js(config_options)
      javascript_tag config_js, type: 'application/javascript'
    end
    
  end
end

ActiveSupport.on_load :action_view do
  include Wechat::Helpers
end
