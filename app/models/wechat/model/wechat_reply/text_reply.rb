module Wechat
  module Model::Reply::TextReply
    extend ActiveSupport::Concern

    included do
      attribute :msg_type, :string, default: 'text'
    end

    def content
      { Content: value }
    end

  end
end
