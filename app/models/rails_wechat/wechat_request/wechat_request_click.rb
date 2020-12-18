module RailsWechat::WechatRequest::WechatRequestClick
  extend ActiveSupport::Concern

  included do
  end

  def rule_tag
    {
      msg_type: msg_type,
      event: event&.downcase,
      body: body
    }.compact
  end

end
