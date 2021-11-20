module Wechat
  module Model::Request::VoiceRequest

    def set_body
      self.body = raw_body['Recognition'].presence || raw_body['MediaId']
    end

  end
end
