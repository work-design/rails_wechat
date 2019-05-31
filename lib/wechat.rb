require 'base64'
require 'openssl/cipher'
require 'wechat/api_loader'
require 'wechat/api'
require 'wechat/helpers'
require 'action_controller/wechat_responder'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'

  class AccessTokenExpiredError < StandardError; end
  class InvalidCredentialError < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end
  

  def self.config(account)
    app = WechatConfig.valid.find_by(account: account)
    app || raise("Wechat configuration for #{account} is missing.")
  end

  def self.api(account = :default)
    return @api if defined? @api
    app = ApiLoader.config(account)

    case app.type
    when 'WechatPublic'
      @api = Wechat::Api::Public.new(app)
    when 'WechatProgram'
      @api = Wechat::Api::Program.new(app)
    when 'WechatWork'
      @api = Wechat::Api::Work.new(app)
    else
      raise 'Account is missing'
    end
  end

  def self.decrypt(encrypted_data, session_key, iv)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.decrypt

    cipher.key = Base64.decode64(session_key)
    cipher.iv = Base64.decode64(iv)
    decrypted_data = Base64.decode64(encrypted_data)
    JSON.parse(cipher.update(decrypted_data) + cipher.final)
  rescue Exception => e
    { errcode: 41003, errmsg: e.message }
  end
end


