module RailsWechat::WechatReply::MusicReply

  def content(thumb_media_id, **options)
    r = options.slice!(:title, :description, :HQ_music_url)
    options.transform_keys! { |k| k.to_s.camelize.to_sym }
    options.merge! MusicURL: r[:music_url] if r[:music_ul]
    update(
      MsgType: 'music',
      Music: { ThumbMediaId: thumb_media_id }.merge!(options)
    )
  end

end
