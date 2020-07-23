class Wechat::Api::Platform < Wechat::Api::Base

  def initialize(app)
    @app = app
    @client = Wechat::HttpClient.new(API_BASE)
    @access_token = Wechat::AccessToken::Platform.new(@client, app)
  end

  def api_component_token
    body = {
      component_appid: app.appid,
      component_appsecret: app.secret,
      component_verify_ticket: app.verify_ticket
    }

    post 'api_component_token', body
  end

end
