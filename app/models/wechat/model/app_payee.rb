module Wechat
  module Model::AppPayee
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :domain, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid, counter_cache: true
      belongs_to :payee

      has_many :receivers
    end

  end
end
