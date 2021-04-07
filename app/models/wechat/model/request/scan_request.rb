module Wechat
  module Model::Request::ScanRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag
    end

    def get_reply
      self.reply = reply_from_rule
      if self.reply
        return self.reply
      end

      if body.present?
        self.reply = qr_response
      else
        r = responses.map do |wr|
          wr.invoke_effect(self)
        end
        self.reply = r[0]
      end
    end

    def qr_response
      res = responses.find_by(match_value: body)
      res.invoke_effect(self) if res
    end

  end
end
