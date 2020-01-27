module RailsWechat::WechatReply::MusicReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'music'
  end

  def content
    r = options.slice!(:title, :description, :HQ_music_url)
    options.transform_keys! { |k| k.to_s.camelize.to_sym }
    options.merge! MusicURL: r[:music_url] if r[:music_ul]

    {
      Music: { ThumbMediaId: value }.merge!(options)
    }
  end

end
