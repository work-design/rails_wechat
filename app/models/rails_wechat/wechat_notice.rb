module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :link, :string, default: 'index'
    attribute :msg_id, :string
    attribute :status, :string
    attribute :type, :string

    belongs_to :notification
    belongs_to :wechat_template
    belongs_to :wechat_app
    belongs_to :wechat_user, class_name: 'OauthUser'
    belongs_to :wechat_subscribed, optional: true

    before_validation do
      self.link = notification.link
      self.wechat_app ||= wechat_template.wechat_app
      if self.wechat_subscribed
        self.wechat_user ||= wechat_subscribed.wechat_user
      else
        self.wechat_user ||= notification.receiver.wechat_users.find_by(app_id: wechat_app.appid)
      end
    end
    after_create_commit :do_send_later
  end

  def data
    wechat_template.data_mappings.transform_values do |value|
      value[:value] = notification.notifiable_detail[value[:value]]
      value
    end
  end

  def do_send_later
    WechatNoticeSendJob.perform_later(self)
  end

  def do_send
    r = do_send
    if r['errcode'] == 0
      self.update msg_id: r['msgid']
      wechat_subscribed.update sending_at: Time.now if wechat_subscribed
    else
      r
    end
  end

end
