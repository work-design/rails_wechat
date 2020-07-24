# frozen_string_literal: true

class Wechat::Api::Base



  attr_reader :app, :client, :access_token, :jsapi_ticket
  def initialize(app)
    @app = app
    @client = Wechat::HttpClient.new
  end

  def get(path, params: {}, headers: {}, base: nil, as: nil)
    with_access_token(params) do |with_token_params|
      client.get path, headers: headers, params: with_token_params, base: base, as: as
    end
  end

  def post(path, payload, params: {}, headers: {}, base: nil)
    with_access_token(params) do |with_token_params|
      client.post path, payload.to_json, headers: headers, params: with_token_params, base: base
    end
  end

  def post_file(path, file, params: {}, headers: {}, base: nil)
    with_access_token(params) do |with_token_params|
      client.post_file path, file, headers: headers, params: with_token_params, base: base
    end
  end

  protected
  def with_access_token(params = {}, tries = 2)
    yield(params.merge!(access_token: access_token.token))
  rescue Wechat::AccessTokenExpiredError
    access_token.refresh
    retry unless (tries -= 1).zero?
  end

end
