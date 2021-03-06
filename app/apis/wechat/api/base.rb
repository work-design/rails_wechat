# frozen_string_literal: true

class Wechat::Api::Base

  attr_reader :app, :client
  def initialize(app)
    @app = app
    @client = Wechat::HttpClient.new
  end

  def get(path, params: {}, headers: {}, base: nil, as: nil)
    with_access_token(params) do |with_token_params|
      client.get path, headers: headers, params: with_token_params, base: base, as: as
    end
  end

  def post(path, params: {}, headers: {}, base: nil, **payload)
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
    app.refresh_access_token unless app.access_token_valid?
    yield params.merge!(access_token: app.access_token)
  rescue Wechat::AccessTokenExpiredError
    app.refresh_access_token
    retry unless (tries -= 1).zero?
  end

end
