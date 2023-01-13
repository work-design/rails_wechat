module Wechat
  module Model::Menu
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :value, :string
      attribute :appid, :string
      attribute :mp_appid, :string
      attribute :mp_pagepath, :string
      attribute :position, :integer

      belongs_to :parent, class_name: self.base_class.name, optional: true
      has_many :children, -> { order(position: :asc) }, class_name: self.base_class.name, foreign_key: :parent_id, dependent: :nullify

      has_many :app_menus, dependent: :destroy_async
      accepts_nested_attributes_for :app_menus, allow_destroy: true
      has_many :apps, through: :app_menus
      has_many :scenes, through: :app_menus

      scope :roots, -> { where(parent_id: nil) }

      acts_as_list scope: [:parent_id, :organ_id]

      after_save_commit :sync_to_wechat, if: -> { (saved_changes.keys & ['name', 'value', 'mp_appid', 'mp_pagepath']).present? }
    end

    def sync_to_wechat
      scenes.each do |scene|
        scene.sync_menu
      end
    end

  end
end
