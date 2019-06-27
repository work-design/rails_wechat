module Wechat::Message
  class Push::Work < Push
    # see: https://work.weixin.qq.com/api/doc#90000/90135/90236/消息类型
    MSG_TYPE = [
      'text', 'markdown',  # content
      'voice', 'image', 'file',  # media_id
      'video',  # media_id, title*, description*
      'textcard',  # title, description, url, btntxt*
      'news',  # articles[], title, url, description*, picurl*
      'mpnews', # articles[], title, thumb_media_id, content, author*, content_source_url*, digest*
      'miniprogram_notice',
      'taskcard'
    ].freeze
  
    def restore
      case msgtype
      when 'news', 'mpnews'
        @message_hash[msgtype] = { articles: @message_hash.delete('articles') }
      end
      
      super
    end

    def to(*user)
      update(touser: user.join('|'))
    end

    def to_all
      update(touser: '@all')
    end
    
    def to_party(*party)
      update(toparty: party.join('|'))
    end
    
    def to_tag(*tag)
      update(totag: tag.join('|'))
    end
    
  end
end
