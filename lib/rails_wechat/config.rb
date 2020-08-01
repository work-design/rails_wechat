module RailsWechat
  include ActiveSupport::Configurable

  configure do |config|
    config.httpx = {
      ssl: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    }
    config.email_domain = 'mail.work.design'
    config.x = ActiveSupport::OrderedOptions.new
    config.x.xx = ->() {

    }
  end

end
