module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag
    end

  end
end
