class Wechat::Message::RepliedWork
  
  def agent_id(agentid)
    update(AgentId: agentid)
  end
  
  
  def textcard(title, description, url, btntxt = nil)
    data = {
      title: title,
      description: description,
      url: url
    }
    data[:btntxt] = btntxt if btntxt.present?
    update(MsgType: 'textcard', TextCard: data)
  end
  
  def markdown(content)
    update(MsgType: 'markdown', Markdown: {
      content: content
    })
  end

  def ref_mpnews(media_id)
    update(MsgType: 'ref_mpnews', MpNews: { MediaId: media_id })
  end
  
  def mpnews(collection, &_block)
    if block_given?
      article = MpNewsArticleBuilder.new
      collection.take(8).each_with_index { |item, index| yield(article, item, index) }
      items = article.items
    else
      items = collection.collect do |item|
        camelize_hash_keys(item.symbolize_keys.slice(:thumb_media_id, :title, :content, :author, :content_source_url, :digest, :show_cover_pic).reject { |_k, v| v.nil? })
      end
    end
  
    update(MsgType: 'mpnews', Articles: items.collect { |item| camelize_hash_keys(item) })
  end

  def file(media_id)
    update(MsgType: 'file', File: { MediaId: media_id })
  end

end
