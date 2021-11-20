module Wechat
  module Model::Request::LocationRequest

    def set_body
      self.body = "#{raw_body['Location_X']}:#{raw_body['Location_Y']}"
    end

  end
end
