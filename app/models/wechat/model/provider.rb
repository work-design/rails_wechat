module Wechat
  module Model::Provider
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string
      attribute :provider_secret, :string
      attribute :suite_id, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
    end


  end
end
