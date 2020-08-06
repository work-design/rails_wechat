module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :link, :string, default: 'index'
    attribute :msg_id, :string
    attribute :status, :string
    attribute :type, :string
    attribute :appid, :string

    belongs_to :notification
    belongs_to :wechat_template
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid
    belongs_to :wechat_user, class_name: 'OauthUser'
    belongs_to :wechat_subscribed, optional: true

    before_validation do
      self.link = notification.link
      self.wechat_app ||= wechat_template.wechat_app
      #self.wechat_subscribed = wechat_user.wechat_subscribed  todo  deal with
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
