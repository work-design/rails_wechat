class Wechat::Message::Base

  def content_blank?
    case @message_hash['MsgType']
    when 'image', 'voice', 'video', 'music'
      !@message_hash.key?(@message_hash['MsgType'].classify)
    when 'news'
      !@message_hash.key?('Articles')
    when 'text'
      @message_hash[:Content].blank?
    else
      false
    end
  end

end
