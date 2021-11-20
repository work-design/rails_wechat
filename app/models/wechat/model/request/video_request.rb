module Wechat
  module Model::Request::VideoRequest

    def set_body
      self.body = raw_body['MediaId']
    end

  end
end
