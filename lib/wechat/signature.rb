module Wechat
  module Signature
    extend self
    
    def hexdigest(token, timestamp, nonce, msg_encrypt = nil)
      array = [token, timestamp, nonce]
      array << msg_encrypt if msg_encrypt
      dev_msg_signature = array.compact.collect(&:to_s).sort.join
      Digest::SHA1.hexdigest(dev_msg_signature)
    end
    
  end
end
