class Wechat::Api::Platform < Wechat::Api::Base

  def initialize(app)
    super
    @access_token = Wechat::AccessToken::Platform.new(@client, app)
  end

  protected
  def with_access_token(params = {}, tries = 2)
    yield(params.merge!(component_access_token: access_token.token))
  rescue Wechat::AccessTokenExpiredError
    access_token.refresh
    retry unless (tries -= 1).zero?
  end

end
