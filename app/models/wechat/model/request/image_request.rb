module Wechat
  module Model::Request::ImageRequest

    def set_body
      self.body = raw_body['PicUrl']
    end

  end
end
