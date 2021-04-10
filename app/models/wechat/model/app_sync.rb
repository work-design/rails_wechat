module Wechat
  module Model::AppSync
    extend ActiveSupport::Concern

    included do
      has_many :menus, foreign_key: :appid, primary_key: :appid
      has_many :receives, foreign_key: :appid, primary_key: :appid
      has_many :replies, foreign_key: :appid, primary_key: :appid
      has_many :requests, foreign_key: :appid, primary_key: :appid
      has_many :responses, foreign_key: :appid, primary_key: :appid
      has_many :services, foreign_key: :appid, primary_key: :appid
      has_many :wechat_users, foreign_key: :appid, primary_key: :appid
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def sync_from_menu
      r = api.menu
      present_menus = r.dig('menu', 'button')
      present_menus.each do |present_menu|
        if present_menu['sub_button'].present?
          parent = self.menus.build(type: 'ParentMenu', name: present_menu['name'])
          present_menu['sub_button'].each do |sub|
            parent.children.build(appid: appid, name: sub['name'], menu_type: sub['type'], value: sub['url'] || sub['key'])
          end
          parent.save
        end
      end
    end

  end
end
