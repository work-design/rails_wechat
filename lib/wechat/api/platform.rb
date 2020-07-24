class Wechat::Api::Platform < Wechat::Api::Base

  def initialize(app)
    super
    @access_token = Wechat::AccessToken::Platform.new(@client, app)
  end

end
