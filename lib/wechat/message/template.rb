class Wechat::Message::Template < Wechat::Message::Base

  attr_reader :notice
  def initialize(notice, msg = {})
    super(app)

    @notice = notice
    to_message
  end

  def to_user(openid, **options)
    @message_hash.merge!(touser: openid, **options)
  end



end
