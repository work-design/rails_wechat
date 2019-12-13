module RailsWechat
  include ActiveSupport::Configurable

  configure do |config|
    config.app_controller = 'ApplicationController'
    config.admin_controller = 'AdminController'
    config.my_controller = 'MyController'
    config.httpx_timeout = {}
    config.httpx_ssl = {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  end

end
