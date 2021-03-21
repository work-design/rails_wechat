module Wechat
  module Model::WechatNotice
    extend ActiveSupport::Concern

    included do
      attribute :link, :string, default: 'index'
      attribute :msg_id, :string
      attribute :status, :string
      attribute :type, :string
      attribute :appid, :string
      attribute :open_id, :string

      belongs_to :notification
      belongs_to :wechat_template
      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :wechat_user, class_name: 'OauthUser', foreign_key: :open_id, primary_key: :uid
      belongs_to :wechat_subscribed, optional: true

      before_validation do
        self.link = notification.link
        self.app ||= wechat_template.app
        #self.wechat_subscribed = wechat_user.wechat_subscribed  todo  deal with
      end
      after_create_commit :do_send_later
    end

    def data
      r = {}
      wechat_template.data_mappings.each do |key, value|
        if key == 'first' && value[:value].blank?
          r.merge! first: { value: notification.title }
        else
          r.merge! key => {
            value: notification.notifiable_detail[value[:value]]
          }
        end
      end
      r
    end

    def do_send_later
      WechatNoticeSendJob.perform_later(self)
    end

    def do_send
      r = do_send
      if r['errcode'] == 0
        self.update msg_id: r['msgid']
        wechat_subscribed.update sending_at: Time.current if wechat_subscribed
      else
        r
      end
    end

  end
end
