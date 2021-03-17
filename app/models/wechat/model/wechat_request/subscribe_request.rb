module Wechat
  module Model::WechatRequest::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :sync_to_tag
    end

    def reply
      r = reply_from_rule
      return r if r

      if body.present?
        qr_response
      else
        r = wechat_responses.map do |wr|
          wr.invoke_effect(self)
        end
        r[0]
      end
    end

    def qr_response
      key = body.delete_prefix('qrscene_')
      res = wechat_responses.find_by(match_value: key)
      res.invoke_effect(self) if res
    end

    def sync_to_tag
      wechat_tag = wechat_tags.find_or_create_by(name: body)
      if wechat_user
        wechat_user.wechat_user_tags.find_or_create_by(wechat_tag_id: wechat_tag.id)
      end
    end

  end
end
