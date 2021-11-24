module Wechat
  module Model::Request::UnsubscribeRequest

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = self.event_key
    end

  end
end
