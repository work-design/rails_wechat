module Wechat
  module Model::Request::MsgRequest
    extend ActiveSupport::Concern

    included do
      belongs_to :template, ->(o){ where(appid: o.appid) }, foreign_key: :body, primary_key: :template_id, optional: true
    end

    def set_body
      if raw_body.dig('List', 'SubscribeStatusString') == 'accept'
        self.body = raw_body.dig('List', 'TemplateId')
      end
    end

  end
end
