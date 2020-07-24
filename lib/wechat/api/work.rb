# frozen_string_literal: true

class Wechat::Api::Work < Wechat::Api::Base
  require 'wechat/api/work/agent'
  include Wechat::Api::Work::Agent


  def initialize(app)
    super
    @client = Wechat::HttpClient.new
    @access_token = Wechat::AccessToken::Work.new(@client, app)
    @agentid = app.agentid
    @jsapi_ticket = Wechat::JsapiTicket::Work.new(@client, app, @access_token)
  end

end
