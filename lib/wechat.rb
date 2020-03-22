# frozen_string_literal: true

require 'wechat/errors'
require 'wechat/api'
require 'wechat/helpers'
require 'wechat/signature'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'

end
