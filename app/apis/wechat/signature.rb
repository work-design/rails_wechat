module Wechat
  module Signature
    extend self

    def hexdigest(token, timestamp, nonce, msg_encrypt = nil)
      array = [token, timestamp, nonce]
      array << msg_encrypt if msg_encrypt
      dev_msg_signature = array.compact.map(&:to_s).sort.join
      Digest::SHA1.hexdigest(dev_msg_signature)
    end

    # Obtain the wechat jssdk config signature parameter and return below hash
    #  params = {
    #    noncestr: noncestr,
    #    timestamp: timestamp,
    #    jsapi_ticket: ticket,
    #    url: url,
    #    signature: signature
    #  }
    def signature(ticket, url)
      deal_url = url.split('#')[0]
      params = {
        noncestr: SecureRandom.base64(16),
        timestamp: Time.current.to_i,
        jsapi_ticket: ticket,
        url: deal_url
      }
      pairs = params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      result = Digest::SHA1.hexdigest pairs
      params.merge(signature: result)
    end

  end
end
