module Wechat
  module Model::Menu
    extend ActiveSupport::Concern
    include Inner::Menu

    TYPE = {
      'view' => 'Wechat::ViewMenu',
      'click' => 'Wechat::ClickMenu',
      'miniprogram' => 'Wechat::MiniProgramMenu',
      'scancode_push' => 'Wechat::ScanPushMenu',
      'scancode_waitmsg' => 'Wechat::ScanWaitMenu'
    }.freeze

    included do
      attribute :position, :integer

      belongs_to :menu_root

      has_many :menu_apps, dependent: :destroy_async
      has_many :apps, through: :menu_apps
      has_many :scenes, through: :menu_apps

      positioned on: [:menu_root_id]

      #after_save_commit :sync_to_wechat, if: -> { (saved_changes.keys & ['name', 'value', 'mp_appid', 'mp_pagepath']).present? }
    end

    def sync_to_wechat
      scenes.each do |scene|
        scene.sync_menu
      end
    end

  end
end
