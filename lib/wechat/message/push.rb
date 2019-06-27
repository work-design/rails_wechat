module Wechat::Message
  class Push < Base
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
      @msgtype = @message_hash['msgtype'].to_s
    end
    
    def restore
      case msgtype
      when 'text', 'markdown'
        @message_hash[msgtype] = { content: @message_hash.delete('content') }
      end
    end
    
    def template(opts = {})
      template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
      update(MsgType: 'template', Template: template_fields)
    end
    
  end
end
