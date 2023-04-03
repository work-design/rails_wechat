module Wechat
  module Model::Menu
    extend ActiveSupport::Concern
    TYPE = {
      'view' => 'Wechat::ViewMenu',
      'click' => 'Wechat::ClickMenu',
      'miniprogram' => 'Wechat::MiniProgramMenu',
      'scancode_push' => 'Wechat::ScanPushMenu',
      'scancode_waitmsg' => 'Wechat::ScanWaitMenu'
    }.freeze

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :value, :string
      attribute :mp_appid, :string
      attribute :mp_pagepath, :string
      attribute :position, :integer
      attribute :root_position, :integer
      attribute :appid, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      belongs_to :menu_root, ->(o){ where(organ_id: o.organ_id) }, foreign_key: :root_position, primary_key: :position, optional: true

      has_many :menu_apps, dependent: :destroy_async
      accepts_nested_attributes_for :menu_apps, allow_destroy: true
      has_many :apps, through: :menu_apps
      has_many :scenes, through: :menu_apps

      acts_as_list scope: [:root_position, :organ_id, :appid]

      after_save_commit :sync_to_wechat, if: -> { (saved_changes.keys & ['name', 'value', 'mp_appid', 'mp_pagepath']).present? }
    end

    def sync_to_wechat
      scenes.each do |scene|
        scene.sync_menu
      end
    end

  end
end
