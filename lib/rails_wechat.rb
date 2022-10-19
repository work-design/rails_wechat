# frozen_string_literal: true

#require 'zeitwerk'
#loader = Zeitwerk::Loader.for_gem
#loader.ignore("#{__dir__}/rails_wechat/config")
#loader.ignore("#{__dir__}/wx_pay/config")
#loader.setup # ready!

# engine
require 'rails_wechat/engine'
require 'rails_wechat/config'

# omniauth
#require 'omniauth/strategies/wechat'
#require 'omniauth/strategies/wechat_qiye'
#require 'omniauth/strategies/wechat_qr'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'receive', 'receives'
  inflect.irregular 'media', 'medias'
end
