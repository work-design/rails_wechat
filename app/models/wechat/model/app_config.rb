module Wechat
  module Model::AppConfig
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :service_url, :string
      attribute :service_corp, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid

      normalizes :service_url, :service_corp, with: -> (value) { value.strip }

      after_create_commit :bind_work, if: -> { service_corp_changed? }
    end

    def bind_work
      app.api.work_bind(value)
    end

  end
end

