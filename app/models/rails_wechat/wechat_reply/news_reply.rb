module RailsWechat::WechatReply::NewsReply


  def content
    items = body.map do |item|
      item.slice(:title, :description, :pic_url, :url).transform_keys! { |k| k.to_s.camelize.to_sym }
    end

    update(MsgType: 'news', ArticleCount: items.count, Articles: items)
  end

end
