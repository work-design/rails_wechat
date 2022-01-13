module Wechat
  module Model::Request::ViewRequest

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey']
      self.body = raw_body['MenuId']
    end

  end
end
