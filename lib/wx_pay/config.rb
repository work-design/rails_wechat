module WxPay
  include ActiveSupport::Configurable

  configure do |config|
    config.sandbox = false
    config.pid = nil
    config.appid = nil
    config.target_id = nil
    config.oauth_callback = nil
    config.return_url = nil
    config.notify_url = nil
    config.return_rsa = ''
  end

end
