module Wechat
  module Model::Request::LinkRequest

    def set_body
      self.body = self.raw_body['Url']
    end

  end
end
