module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag
    end

    def reply_from_response
      if body.present?
        res = responses.find_by(match_value: body)
      else
        res = responses[0]
      end

      res.invoke_effect(self) if res
    end

  end
end
