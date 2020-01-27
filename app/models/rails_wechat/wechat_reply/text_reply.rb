module RailsWechat::WechatReply::TextReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'text'
  end

  def content
    { Content: value }
  end

  def xx
    if wechat_user.user.nil?
      msg = received.app.help_without_user
    elsif wechat_user.user.disabled?
      msg = received.app.help_user_disabled
    else
      msg = wechat_request.response
    end
  end

end
