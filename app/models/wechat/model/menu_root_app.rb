module Wechat
  module Model::MenuRootApp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :appid, :string
      attribute :position, :integer

      belongs_to :menu_root, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      has_many :menus, -> { order(position: :asc) }, primary_key: :menu_root_id, foreign_key: :menu_root_id
      has_many :menu_apps, -> { order(position: :asc) }

      acts_as_list scope: [:menu_root_id, :appid]
    end

  end
end
