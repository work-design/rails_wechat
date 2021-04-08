module Wechat
  module Model::Request::ScanRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag
    end

    def reply_from_response
      if body.present?
        res = responses.find_by(match_value: body)
        res.invoke_effect(self) if res
      else
        r = responses.map do |wr|
          wr.invoke_effect(self)
        end
        r[0]
      end
    end

  end
end
