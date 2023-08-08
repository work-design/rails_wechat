module Wechat
  module Model::Category
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :level, :integer
      attribute :scope, :string
      attribute :kind, :string
      attribute :extra, :json

      scope :roots, -> { where(parent_id: 0) }
    end

  end
end
