class Wechat::Message::Base
  attr_reader :message_hash, :api

  def initialize(app, msg = {})
    @api = app.api
    @message_hash = msg
  end

  def [](key)
    @message_hash[key]
  end

  def to_xml
    @message_hash.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
  end

  def to_json
    @message_hash.to_json
  end

  def save_to_db!
    model = WechatRequest.new
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

    if @wechat_app.encrypt_mode
      _encrypt = Base64.strict_encode64(Cipher.encrypt(Cipher.pack(msg, @we_app_id), @wechat_app.encoding_aes_key))
      msg = encrypt(_encrypt, params[:timestamp], params[:nonce])
    end

    msg
  end

  def do_encrypt(encrypt, timestamp, nonce)
    msg_sign = Signature.hexdigest(@wechat_app.token, timestamp, nonce, encrypt)

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
