module Wechat
  module Model::Request::SubscribeRequest
    extend ActiveSupport::Concern

    included do
      before_save :sync_to_tag, unless: -> { body.to_s.start_with?('session_') }
    end

  end
end
