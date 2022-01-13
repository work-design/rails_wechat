module Wechat
  module Model::NewsReplyItem
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :description, :string
      attribute :url, :string
      attribute :raw_pic_url, :string

      belongs_to :news_reply

      has_one_attached :pic
    end

    def to_wechat
      {
        Title: title,
        Description: description,
        PicUrl: pic_url,
        Url: url
      }
    end

    def pic_url
      raw_pic_url.presence || pic.url
    end

  end
end
