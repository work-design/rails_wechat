class Wechat::Message::Base
  TO_JSON_KEY_MAP = {
    'TextCard' => 'textcard',
    'Markdown' => 'markdown',
    'ToUserName' => 'touser',
    'ToPartyName' => 'toparty',
    'ToWxName' => 'towxname',
    'MediaId' => 'media_id',
    'MpNews' => 'mpnews',
    'ThumbMediaId' => 'thumb_media_id',
    'TemplateId' => 'template_id',
    'FormId' => 'form_id',
    'ContentSourceUrl' => 'content_source_url',
    'ShowCoverPic' => 'show_cover_pic'
  }.freeze
  
  TO_JSON_ALLOWED = [
    'touser',
    'toparty',
    'msgtype',
    'content', 'image', 'voice', 'video', 'file', 'textcard', 'markdown', 'music', 'news', 'articles',
    'template', 'agentid', 'filter',
    'send_ignore_reprint', 'mpnews', 'towxname',
  ].freeze
  
  def initialize(body)
    @message_hash ||= {}
  end

  def [](key)
    @message_hash[key]
  end

  def to_xml
    @message_hash.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
  end
  
  def to_json
    keep_camel_case_key = @message_hash[:MsgType] == 'template'
    json_hash = deep_recursive(@message_hash) do |key, value|
      key = key.to_s
      [(TO_JSON_KEY_MAP[key] || (keep_camel_case_key ? key : key.downcase)), value]
    end
    json_hash = json_hash.transform_keys(&:downcase).select { |k, _v| TO_JSON_ALLOWED.include? k }
  
    case json_hash['msgtype']
    when 'text'
      json_hash['text'] = { 'content' => json_hash.delete('content') }
    when 'news'
      json_hash['news'] = { 'articles' => json_hash.delete('articles') }
    when 'mpnews'
      json_hash = { 'articles' => json_hash['articles'] }
    when 'ref_mpnews'
      json_hash['msgtype'] = 'mpnews'
      json_hash.delete('articles')
    when 'template'
      json_hash = { 'touser' => json_hash['touser'] }.merge!(json_hash['template'])
    end
    JSON.generate(json_hash)
  end

  def save_to_db!
    model = WechatFeedback.new
    model.body = @message_hash
    model.save!
    self
  end

  def process_response(response)
    if response[:MsgType] == 'success'
      msg = 'success'
    else
      msg = response.to_xml
    end
  
    if @wechat_config.encrypt_mode
      _encrypt = Base64.strict_encode64(Cipher.encrypt(Cipher.pack(msg, @we_app_id), @wechat_config.encoding_aes_key))
      msg = encrypt(_encrypt, params[:timestamp], params[:nonce])
    end
  
    msg
  end

  def encrypt(encrypt, timestamp, nonce)
    msg_sign = Signature.hexdigest(@wechat_config.token, timestamp, nonce, encrypt)
  
    {
      Encrypt: encrypt,
      MsgSignature: msg_sign,
      TimeStamp: timestamp,
      Nonce: nonce
    }
  end
  
  private
  def update(fields = {})
    @message_hash.merge!(fields)
    self
  end
  
end
