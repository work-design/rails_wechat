module Wechat
  module Model::Message::MessageSend
    extend ActiveSupport::Concern

    included do
      has_one :reply
    end

  end
end
