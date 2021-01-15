module Wechat
  module RailsWechat::NewsReplyItem
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :description, :string
      attribute :pic_url, :string
      attribute :url, :string

      belongs_to :news_reply
    end

    def to_wechat
      {
        Title: title,
        Description: description,
        PicUrl: pic_url,
        Url: url
      }
    end

  end
end
