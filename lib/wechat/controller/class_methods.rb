module ClassMethods
  
  def on(msg_type, event: nil, with: nil, &block)
    raise 'Unknown message type' unless MESSAGE_TYPE.include?(message_type)
    config = { msg_type: msg_type }
    config[:proc] = block if block_given?
    
    if with.present?
      unless WITH_TYPE.include?(message_type)
        warn "Only #{WITH_TYPE.join(', ')} can having :with parameters", uplevel: 1
      end
      
      case with
      when String
        config[:with_string] = with
      when Regexp
        config[:with_regexp] = with
      else
        raise 'With is only support String or Regexp!'
      end
    else
      raise "Message type #{MUST_WITH.join(', ')} must specify :with parameters" if MUST_WITH.include?(message_type)
    end
    
    if msg_type == :event
      config[:event] = event
    end
    
    @configs << config
    config
  end

end
