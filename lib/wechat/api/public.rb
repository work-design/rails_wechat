# frozen_string_literal: true
require 'wechat/api/base/cgi_bin'

class Wechat::Api::Public < Wechat::Api::Base
  include Wechat::Api::Base::CgiBin

  def initialize(app)
    super
    @access_token = Wechat::AccessToken::Public.new(@client, app)
    @jsapi_ticket = Wechat::JsapiTicket::Public.new(@client, app, @access_token)
  end

end
