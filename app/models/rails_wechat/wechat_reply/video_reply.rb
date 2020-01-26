module RailsWechat::WechatReply::VideoReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'video'
  end

  def video(media_id, **options)
    options.slice!(:title, :description)
    options.transform_keys! { |k| k.to_s.camelize.to_sym }

    update(
      MsgType: 'video',
      Video: { MediaId: media_id }.merge!(options)
    )
  end


end
