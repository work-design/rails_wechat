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

      positioned on: [:menu_root_id, :appid]
    end

    def app_menus(_)
      r = []
      menu_apps.each do |menu_app|
        if menu_app.menu
          r.insert r.index(menu_app.menu) + 1, menu_app
        else
          r.insert -(r.size + 1), menu_app
        end
      end
      r
    end

  end
end
