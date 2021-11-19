module Wechat
  module Model::Notice
    extend ActiveSupport::Concern

    included do
      attribute :link, :string, default: 'index'
      attribute :msg_id, :string
      attribute :status, :string
      attribute :type, :string
      attribute :appid, :string
      attribute :open_id, :string

      belongs_to :notification
      belongs_to :template
      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid
      belongs_to :subscribe, optional: true

      before_validation do
        self.link = notification.link
        self.app ||= template.app
        #self.subscribe = wechat_user.subscribe  todo  deal with
      end
      after_create_commit :do_send_later
    end

    def data
      r = {}
      template.data_mappings.each do |key, value|
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
      NoticeSendJob.perform_later(self)
    end

    def do_send
      r = do_send
      if r['errcode'] == 0
        self.update msg_id: r['msgid']
        subscribe.update sending_at: Time.current if subscribe
      else
        r
      end
    end

  end
end
