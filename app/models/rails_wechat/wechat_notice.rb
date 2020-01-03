module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    belongs_to :wechat_template
    belongs_to :wechat_app
    belongs_to :wechat_user
    has_many :wechat_subscribeds

    before_validation do
      self.wechat_app = wechat_template.wechat_app
    end
  end

  def to_wechat
    msg = Wechat::Message::Template::Program.new(wechat_template)
    msg.do_send
  end


end
