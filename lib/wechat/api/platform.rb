class Wechat::Api::Platform < Wechat::Api::Base


  def initialize(app)
    @app = app
    @client = Wechat::HttpClient.new
    @access_token = Wechat::AccessToken::Platform.new(@client, app)
  end


end
