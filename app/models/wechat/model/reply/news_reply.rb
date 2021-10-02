module Wechat
  module Model::Reply::NewsReply
    extend ActiveSupport::Concern

    included do
      attribute :msg_type, :string, default: 'news'

      has_many :news_reply_items, dependent: :delete_all
      accepts_nested_attributes_for :news_reply_items
    end

    def content
      items = news_reply_items.map do |item|
        item.to_wechat
      end

      {
        ArticleCount: items.count,
        Articles: items
      }
    end

    def has_content?
      content[:Articles].present?
    end

  end
end
