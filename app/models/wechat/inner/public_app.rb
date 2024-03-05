# frozen_string_literal: true

module Wechat
  module Inner::PublicApp
    extend ActiveSupport::Concern

    def oauth_enable
      true
    end

    def domain
      organ&.host || (defined?(SETTING) && SETTING.host)
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Public.new(self)
    end

    def sync_menu
      api.menu_delete
      api.menu_create menu
    end

    def menu_roots
      r = MenuRoot.includes(:menus).order(position: :asc).to_a
      menu_root_apps.includes(:menu_root).order(position: :desc).each do |menu_root_app|
        if menu_root_app.menu_root
          r.insert r.index(menu_root_app.menu_root) + 1, menu_root_app
        else
          r.insert -(r.size + 1), menu_root_app
        end
      end
      r
    end

    def menu
      r = menu_roots.map do |menu_root|
        if menu_root.is_a?(MenuRoot)
          _subs = menu_root.app_menus(appid).delete_if { |i| i.is_a?(Menu) && menu_disables.pluck(:menu_id).include?(i.id) }
        else
          _subs = menu_root.menu_apps
        end

        subs = _subs[0..4].as_json(host: domain.split(':')[0])
        if subs.size <= 1
          subs[0]
        else
          { name: menu_root.name, sub_button: subs }
        end
      end.compact

      { button: r[0..2] }
    end

    def js_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      js_hash = Wechat::Signature.signature(jsapi_ticket, url)
      js_hash.merge! appid: appid
      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
      {}
    end

    def update_open_appid!
      r = api.open_get
      if r['errcode'] == 0
        self.update open_appid: r['open_appid']
      else
        r = api.open_create
        self.update open_appid: r['open_appid']
      end
    end

  end
end
