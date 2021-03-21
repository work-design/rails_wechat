module Wechat
  module Model::WechatRequest::ScanRequest

    def reply
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
      key = body.delete_prefix('qrscene_')
      res = responses.find_by(match_value: key)
      res.invoke_effect(self) if res
    end

  end
end
