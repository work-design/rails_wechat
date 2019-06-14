module RailsWechat
  include ActiveSupport::Configurable

  configure do |config|
    config.app_controller = 'ApplicationController'
    config.admin_controller = 'AdminController'
    config.timeout = 20
    config.skip_verify_ssl = true
  end

end
