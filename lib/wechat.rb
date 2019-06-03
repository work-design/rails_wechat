require 'wechat/api'
require 'wechat/helpers'
require 'wechat/errors'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'
  
  def self.config(account)
    WechatConfig.valid.find_by(account: account)
  end

  def self.api(account = :default)
    app = config(account)
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


