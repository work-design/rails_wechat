module RailsWechat::WechatReply::NewsReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'news'

    has_many :news_reply_items, dependent: :delete_all
    accepts_nested_attributes_for :news_reply_items
  end

  def content
    items = body.map do |item|
      item.slice(:title, :description, :pic_url, :url).transform_keys! { |k| k.to_s.camelize.to_sym }
    end

    {
      ArticleCount: items.count,
      Articles: items
    }
  end

end
