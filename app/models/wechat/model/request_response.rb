module Wechat
  module Model::RequestResponse
    extend ActiveSupport::Concern

    included do
      attribute :request_type, :string
      attribute :appid, :string

      belongs_to :response
      belongs_to :request, ->(o) { where(appid: o.appid) }, foreign_key: :request_type, primary_key: :type, optional: true
    end

    def type_text
      Wechat::Request.enum_i18n :type, request_type
    end

  end
end

