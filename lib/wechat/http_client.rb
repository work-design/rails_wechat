require 'httpx'
require 'http/form_data'

class Wechat::HttpClient

  def initialize(base)
    @base = base
    @http = HTTPX.with(**RailsWechat.config.httpx)
  end

  def get(path, headers: {}, params: {}, **options)
    headers['Accept'] ||= 'application/json'
    base = options[:base].presence || @base
    url = base + path

    response = @http.headers(headers).get(url, params: params)
    parse_response(response, options[:as])
  end

  def post(path, payload, headers: {}, params: {}, **options)
    headers['Accept'] ||= 'application/json'
    headers['Content-Type'] ||= 'application/json'
    base = options[:base].presence || @base
    url = base + path

    response = @http.headers(headers).post(url, params: params, body: payload)
    parse_response(response, options[:as])
  end

  def post_file(path, file, headers: {}, params: {}, **options)
    headers['Accept'] ||= 'application/json'
    base = options[:base].presence || @base
    url = base + path

    form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file)
    response = @http.plugin(:multipart).headers(headers).post(
      url,
      params: params,
      form: { media: form_file }
    )
    parse_response(response, options[:as])
  end

  private
  def parse_response(response, parse_as)
    raise "Request not OK, response status #{response.status}" if response.status != 200

    content_type = response.content_type.mime_type
    body = response.body.to_s

    if content_type =~ /image|audio|video/
      data = Tempfile.new('tmp')
      data.binmode
      data.write(body)
      data.rewind
      return data
    elsif content_type =~ /html|xml/
      data = Hash.from_xml(body)
    else
      data = JSON.parse body.gsub(/[\u0000-\u001f]+/, '')
    end

    case data['errcode']
    when 0 # for request didn't expect results
      data
      # 42001: access_token timeout
      # 40014: invalid access_token
      # 40001, invalid credential, access_token is invalid or not latest hint
      # 48001, api unauthorized hint, should not handle here # GH-230
    when 42001, 40014, 40001, 41001
      raise Wechat::AccessTokenExpiredError
      # 40029, invalid code for mp # GH-225
      # 43004, require subscribe hint # GH-214
    when 2
      raise Wechat::ResponseError.new(data['errcode'], data['errmsg'])
    else
      data
    end
  end

end
