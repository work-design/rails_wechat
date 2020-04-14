module RailsWechat
  include ActiveSupport::Configurable

  configure do |config|
    config.app_controller = 'ApplicationController'
    config.admin_controller = 'AdminController'
    config.panel_controller = 'PanelController'
    config.my_controller = 'MyController'
    config.httpx = {
      ssl: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    }
  end

end
