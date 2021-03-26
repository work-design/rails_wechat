module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :sync_to_tag
    end

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
      key = body.delete_prefix('qrscene_')
      res = responses.find_by(match_value: key)
      res.invoke_effect(self) if res
    end

    def sync_to_tag
      tag = tags.find_or_create_by(name: body)
      if wechat_user
        wechat_user.user_tags.find_or_create_by(tag_id: tag.id)
      end
    end

  end
end
