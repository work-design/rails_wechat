# frozen_string_literal: true

require 'openssl/cipher'
require 'base64'

module Wechat::Cipher
  extend self

  def encrypt(plain, encoding_aes_key)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.padding = 0

    aes_key = Base64.decode64(encoding_aes_key + '=')
    cipher.key = aes_key
    cipher.iv = [aes_key].pack('H*')

    cipher.update(plain) + cipher.final
  end

  # 第三方平台：https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Before_Develop/Technical_Plan.html#加密解密技术方案
  def decrypt(msg, encoding_aes_key)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.decrypt
    cipher.padding = 0

    aes_key = Base64.decode64(encoding_aes_key + '=')
    cipher.key = aes_key
    cipher.iv = [aes_key].pack('H*')

    plain = cipher.update(msg) + cipher.final
    decode_padding(plain)
  end

  def suite_decrypt(msg, encoding_aes_key)

  end

  def program_decrypt(encrypted_data, iv, session_key)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.decrypt

    cipher.key = Base64.decode64(session_key)
    cipher.iv = Base64.decode64(iv)
    decrypted_data = Base64.decode64(encrypted_data)

    JSON.parse(cipher.update(decrypted_data) + cipher.final)
  rescue Exception => e
    { errcode: 41003, errmsg: e.message }
  end

  def pack(content, app_id)
    random = SecureRandom.hex(8)
    text = content.force_encoding('ASCII-8BIT')
    msg_len = [text.length].pack('N')

    encode_padding("#{random}#{msg_len}#{text}#{app_id}")
  end

  def unpack(msg)
    msg = decode_padding(msg)
    msg_len = msg[16, 4].reverse.unpack('V')[0]
    content = msg[20, msg_len]
    app_id = msg[(20 + msg_len)..-1]

    [content, app_id]
  end

  private
  def encode_padding(data)
    length = data.bytes.length
    amount_to_pad = 32 - (length % 32)
    amount_to_pad = 32 if amount_to_pad == 0
    padding = ([amount_to_pad].pack('c') * amount_to_pad)
    data + padding
  end

  def decode_padding(plain)
    pad = plain.bytes[-1]
    # no padding
    pad = 0 if pad < 1 || pad > 32
    plain[0...(plain.length - pad)]
  end

end
