class NewsReplyItem < ApplicationRecord
  include RailsWechat::NewsReplyItem
end unless defined? NewsReplyItem
