class Wechat::Message::Template < Wechat::Message::Base
  attr_reader :notice

  def initialize(notice)
    super notice.wechat_app

    @notice = notice
    to_message
  end

  def to_user(openid, **options)
    update(touser: openid, **options)
  end

end
