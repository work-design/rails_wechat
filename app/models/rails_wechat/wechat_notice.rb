module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :link, :string, default: 'index'

    belongs_to :notification
    belongs_to :wechat_template
    belongs_to :wechat_app
    belongs_to :wechat_user, class_name: 'OauthUser'
    belongs_to :wechat_subscribed, optional: true

    before_validation do
      self.wechat_app = wechat_template.wechat_app
      if self.wechat_subscribed
        self.wechat_user ||= wechat_subscribed.wechat_user
      else
        self.wechat_user ||= notification.receiver.wechat_users.find_by(app_id: wechat_app.appid)
      end
    end
  end

  def data
    wechat_template.data_mappings.transform_values do |value|
      value[:value] = notification.notifiable_detail[value[:value]]
      value
    end
  end

  def to_message
    if wechat_app.is_a?(WechatProgram)
      Wechat::Message::Template::Program.new(self)
    else
      Wechat::Message::Template::Public.new(self)
    end
  end

  def do_send
    r = to_message.do_send
    if r['errcode'] == 0
      wechat_subscribed.update sending_at: Time.now if wechat_subscribed
    else
      r
    end
  end

end
