# frozen_string_literal: true

# engine
require 'rails_wechat/engine'
require 'rails_wechat/config'
require 'rails_wechat/helpers'

# omniauth
#require 'omniauth/strategies/wechat'
#require 'omniauth/strategies/wechat_qiye'
#require 'omniauth/strategies/wechat_qr'

module Wechat

  def self.use_relative_model_naming?
    true
  end

end
