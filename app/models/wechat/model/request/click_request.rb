module Wechat
  module Model::Request::ClickRequest

    def set_body
      self.event = raw_body['Event']
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.body = self.event_key
    end

  end
end
