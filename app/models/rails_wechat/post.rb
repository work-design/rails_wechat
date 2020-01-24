module RailsWechat::Post
  extend ActiveSupport::Concern

  included do
    attribute :thumb_media_id, :string
  end

  def to_wechat
    r = wechat_app.api.material_add_news xx
    if r['media_id']
      post_sync = wechat_app.post_syncs.find_or_initialize_by(source_id: r['media_id'])
      post_sync.post = self
      post_sync.save
    end
  end

  def wechat_app
    return @wechat_app if defined? @wechat_app
    @wechat_app = WechatApp.default
  end

  def xx
    {
      title: title,
      thumb_media_id: thumb_media_id,
      show_cover_pic: 0,
      content: content,
      content_source_url: 'https://one.work'
    }
  end

end
