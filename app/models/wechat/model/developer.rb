module Wechat
  module Model::Developer
    include Common
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
    end

  end
end
