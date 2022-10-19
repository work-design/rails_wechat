require 'wx_pay/result'
require 'wx_pay/sign'
require 'wx_pay/service'
require 'wx_pay/version'
require 'openssl'
require 'zeitwerk'
require 'active_support/configurable'
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module WxPay
  include ActiveSupport::Configurable

  configure do |config|
    config.sandbox = false
    config.pid = nil
    config.appid = nil
    config.target_id = nil
    config.oauth_url = 'https://openauth.alipay.com/oauth2/appToAppAuth.htm'
    config.oauth_callback = nil
    config.return_url = nil
    config.notify_url = nil
    config.return_rsa = ''
    config.rsa2_path = 'config/alipay_rsa2.pem'
  end

end
