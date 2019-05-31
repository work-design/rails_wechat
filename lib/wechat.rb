require 'wechat/api'
require 'wechat/helpers'
require 'action_controller/wechat_responder'

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


