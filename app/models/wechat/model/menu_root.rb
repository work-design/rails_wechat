module Wechat
  module Model::MenuRoot
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :position, :integer

      has_many :menus, -> { where(global: true).order(position: :asc) }, primary_key: :position, foreign_key: :root_position
    end

  end
end
