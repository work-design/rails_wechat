class Wechat::Message::Mass < Wechat::Message::Base
  
  
  attr_reader :msgtype
  def initialize(app, msg = {})
    super
    
    @message_hash['msgtype'] = 'text' if @message_hash['msgtype'].blank?
    
    @msgtype = @message_hash['msgtype'].to_s
    restore
  end
  
  def do_send
  
  end
  
  def restore
    case msgtype
    when 'text', 'markdown'
      @message_hash[msgtype] = { content: @message_hash.delete('content') }
    end
  end
  
end
