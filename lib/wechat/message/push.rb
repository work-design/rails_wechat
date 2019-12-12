class Wechat::Message::Push < Wechat::Message::Base
  
  TEMPLATE_KEYS = [
    'template_id',
    'form_id',
    'page',
    'color',
    'emphasis_keyword',
    'topcolor',
    'url',
    'miniprogram',
    'data'
  ].freeze
  
  attr_reader :msgtype
  def initialize(msg = {})
    @message_hash = Hash(msg).with_indifferent_access
    
    @message_hash['msgtype'] = 'text' if @message_hash['msgtype'].blank?
    
    @msgtype = @message_hash['msgtype'].to_s
    restore
  end
  
  def restore
    case msgtype
    when 'text', 'markdown'
      @message_hash[msgtype] = { content: @message_hash.delete('content') }
    end
  end
  
end
