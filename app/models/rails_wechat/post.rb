module RailsWechat::Post
  extend ActiveSupport::Concern

  included do
    attribute :sync_wechat, :boolean
  end

end
