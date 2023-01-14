module Wechat
  module Model::Menu
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :value, :string
      attribute :mp_appid, :string
      attribute :mp_pagepath, :string
      attribute :position, :integer

      belongs_to :menu_root, optional: true
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :app_menus, dependent: :destroy_async
      accepts_nested_attributes_for :app_menus, allow_destroy: true
      has_many :apps, through: :app_menus
      has_many :scenes, through: :app_menus

      acts_as_list scope: [:menu_root_id, :organ_id]

      after_save_commit :sync_to_wechat, if: -> { (saved_changes.keys & ['name', 'value', 'mp_appid', 'mp_pagepath']).present? }
    end

    def sync_to_wechat
      scenes.each do |scene|
        scene.sync_menu
      end
    end

  end
end
