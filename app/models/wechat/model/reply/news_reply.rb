module Wechat
  module Model::Reply::NewsReply
    extend ActiveSupport::Concern

    included do
      has_many :news_reply_items, dependent: :delete_all
      accepts_nested_attributes_for :news_reply_items
    end

    def msg_type
      'news'
    end

    def content
      items = news_reply_items.map do |item|
        item.to_wechat
      end

      {
        MsgType: 'news',
        ArticleCount: items.count,
        Articles: items
      }
    end

    def has_content?
      content[:Articles].present?
    end

  end
end
