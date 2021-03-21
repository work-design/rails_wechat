module Wechat
  module Model::Reply::MusicReply
    extend ActiveSupport::Concern

    included do
      attribute :msg_type, :string, default: 'music'
    end

    def content
      {
        Music: {
          ThumbMediaId: value,
          Title: title,
          Description: description
        }
      }
    end

  end
end
