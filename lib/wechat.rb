require 'wechat/api'
require 'wechat/helpers'
require 'wechat/errors'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'
  
  def self.config(id = nil)
    if id
      r = WechatConfig.valid.find(id)
    else
      r = WechatConfig.default
    end
    return r if r
    
    raise 'Can not find wechat config'
  end

  def self.api(id = nil)
    app = config(id)
    app_api(app)
  end
  
  def self.app_api(app)
    case app.type
    when 'WechatPublic'
      Wechat::Api::Public.new(app)
    when 'WechatProgram'
      Wechat::Api::Program.new(app)
    when 'WechatWork'
      Wechat::Api::Work.new(app)
    else
      raise 'Account is missing'
    end
  end
  
end


