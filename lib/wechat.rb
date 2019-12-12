# frozen_string_literal: true

require 'wechat/errors'
require 'wechat/api'
require 'wechat/helpers'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'

end
