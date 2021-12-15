module Wechat
  module Model::RequestResponse
    extend ActiveSupport::Concern

    included do
      attribute :request_type, :string
      attribute :appid, :string

      belongs_to :respose

      belongs_to :request, ->(o){ where(appid: o.appid) }, foreign_key: :type, primary_key: :request_type
    end

  end
end

