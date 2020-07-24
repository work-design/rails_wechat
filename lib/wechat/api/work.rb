# frozen_string_literal: true

class Wechat::Api::Work < Wechat::Api::Base
  require 'wechat/api/work/agent'
  require 'wechat/api/work/menu'
  require 'wechat/api/work/user'
  include Agent
  include Menu
  include User

  def initialize(app)
    super
    @access_token = Wechat::AccessToken::Work.new(@client, app)
    @agentid = app.agentid
    @jsapi_ticket = Wechat::JsapiTicket::Work.new(@client, app, @access_token)
  end

end
