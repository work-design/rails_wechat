module Wechat
  module Model::PayeeDomain
    extend ActiveSupport::Concern

    included do
      attribute :mch_id, :string, index: true
      attribute :domain, :string, index: true

      belongs_to :payee, foreign_key: :mch_id, primary_key: :mch_id
    end

  end
end
