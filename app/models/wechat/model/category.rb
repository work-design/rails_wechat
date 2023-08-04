module Wechat
  module Model::Category
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :level, :integer
      attribute :scope, :string
      attribute :kind, :string
      attribute :extra, :json
    end

  end
end
