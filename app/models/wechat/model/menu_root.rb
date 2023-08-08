module Wechat
  module Model::MenuRoot
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :position, :integer

      has_many :menus, -> { order(position: :asc) }
      has_many :menu_root_apps, -> { order(position: :asc) }
    end

  end
end
