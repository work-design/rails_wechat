module Wechat
  module Model::Request::MsgRequest

    def set_body
      if raw_body.dig('List', 'SubscribeStatusString') == 'accept'
        self.body = raw_body.dig('List', 'TemplateId')
      end
    end

  end
end
