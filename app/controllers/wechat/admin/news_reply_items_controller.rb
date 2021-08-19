module Wechat
  class Admin::NewsReplyItemsController < Admin::BaseController
    before_action :set_reply
    before_action :set_news_reply_item

    private
    def set_reply
      @reply = Reply.find(params[:reply_id])
    end

    def set_news_reply_item
      @news_reply_item = @reply.news_reply_items.find params[:id]
    end

  end
end
