module Wechat
  module Inner::App
    extend ActiveSupport::Concern

    included do
      has_many :menu_apps, -> { where(scene_id: nil) }, primary_key: :appid, foreign_key: :appid
      has_many :menus, primary_key: :appid, foreign_key: :appid
      has_many :all_menu_apps, class_name: 'MenuApp', primary_key: :appid, foreign_key: :appid
      has_many :pure_menu_roots, class_name: 'MenuRoot', primary_key: :appid, foreign_key: :appid
      has_many :receives, primary_key: :appid, foreign_key: :appid
      has_many :replies, primary_key: :appid, foreign_key: :appid
      has_many :requests, primary_key: :appid, foreign_key: :appid
      has_many :responses, primary_key: :appid, foreign_key: :appid
      has_many :services, primary_key: :appid, foreign_key: :appid
      has_many :wechat_users, primary_key: :appid, foreign_key: :appid
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def sync_from_menu
      r = api.menu
      present_menus = r.dig('menu', 'button')
      present_menus.each_with_index do |present_menu, index|
        if present_menu['sub_button'].present?
          parent = self.pure_menu_roots.find_or_initialize_by(position: index + 1)
          parent.name = present_menu['name']
          present_menu['sub_button'].each do |sub|
            m = parent.menus.find_or_initialize_by(appid: appid)
            m.name = sub['name']
            #m.type = sub['type']
            m.value = sub['url'] || sub['key']
          end
          parent.save
        else

        end
      end
    end

  end
end
