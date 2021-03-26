module Wechat
  module Model::Request::ScanRequest

    def get_reply
      r = reply_from_rule
      return r if r

      if body.present?
        qr_response
      else
        r = responses.map do |wr|
          wr.invoke_effect(self)
        end
        r[0]
      end
    end

    def qr_response
      res = responses.find_by(match_value: body)
      res.invoke_effect(self) if res
    end

  end
end
