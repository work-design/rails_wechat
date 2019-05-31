module RailsRole
  include ActiveSupport::Configurable
  config_accessor :default_admin_emails

  configure do |config|
    config.app_controller = 'ApplicationController'
    config.admin_controller = 'AdminController'
    config.timeout = 20
    config.skip_verify_ssl = true
  end

end
