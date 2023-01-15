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
      attribute :root_position, :integer

      belongs_to :menu_root, foreign_key: :root_position, primary_key: :position, optional: true
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :menu_apps, dependent: :destroy_async
      accepts_nested_attributes_for :menu_apps, allow_destroy: true
      has_many :apps, through: :menu_apps
      has_many :scenes, through: :menu_apps

      acts_as_list scope: [:menu_root_id, :organ_id]

      before_validation :sync_root_position, if: -> { menu_root_id_changed? }
      after_save_commit :sync_to_wechat, if: -> { (saved_changes.keys & ['name', 'value', 'mp_appid', 'mp_pagepath']).present? }
    end

    def sync_root_position
      self.root_position = menu_root&.position
    end

    def sync_to_wechat
      scenes.each do |scene|
        scene.sync_menu
      end
    end

  end
end
