module RailsWechat::NewsReplyItem
  extend ActiveSupport::Concern
  included do
    attribute :title, :string
    attribute :description, :string
    attribute :pic_url, :string
    attribute :url, :string

    belongs_to :news_reply
  end


end
