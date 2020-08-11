# frozen_string_literal: true

class Wechat::Api::Public < Wechat::Api::Base
  require 'wechat/api/public/base'
  require 'wechat/api/public/material'
  require 'wechat/api/public/menu'
  require 'wechat/api/public/mp'
  require 'wechat/api/public/user'

  include Base
  include Material
  include Menu
  include Mp
  include User

end
