module RailsWechat::WechatReply::NewsReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'news'
  end

  def content
    items = body.map do |item|
      item.slice(:title, :description, :pic_url, :url).transform_keys! { |k| k.to_s.camelize.to_sym }
    end

    update(MsgType: 'news', ArticleCount: items.count, Articles: items)
  end

end
