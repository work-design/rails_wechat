module Wechat
  module Model::AppConfig
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :value, :string

      enum :key, {
        service_url: 'service_url',
        service_corp: 'service_corp'
      }

      belongs_to :app, foreign_key: :appid, primary_key: :appid

      after_create_commit :service_corp, if: -> { key == 'service_corp' }
    end

    def bind_work
      app.api.work_bind(service_corp)
    end

  end
end

