module Wechat
  module Model::AppConfig
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string
      attribute :value, :string

      enum key: {
        service_url: 'service_url',
        service_corp: 'service_corp'
      }

      belongs_to :app, foreign_key: :appid, primary_key: :appid
    end

  end
end

