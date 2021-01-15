module Wechat
  module RailsWechat::WechatAgency
    SERVICE_TYPE = {
      '0' => 'WechatRead',
      '1' => 'WechatRead',
      '2' => 'WechatPublic'
    }.freeze
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :refresh_token, :string
      attribute :func_infos, :string, array: true
      attribute :nick_name, :string
      attribute :head_img, :string
      attribute :user_name, :string
      attribute :principal_name, :string
      attribute :alias_name, :string
      attribute :qrcode_url, :string
      attribute :business_info, :json
      attribute :service_type, :string
      attribute :verify_type, :string

      belongs_to :wechat_platform
      belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true

      after_create_commit :store_info_later
      before_save :init_wechat_app, if: -> { appid_changed? && appid }
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Public.new(self)
    end

    def init_wechat_app
      wechat_app || build_wechat_app
      wechat_app.save
    end

    def refresh_access_token
      r = wechat_platform.api.authorizer_token(appid, refresh_token)
      store_access_token(r)
    end

    def store_info_later
      WechatAgencyJob.perform_later(self)
    end

    def store_info
      r = wechat_platform.api.get_authorizer_info(appid)
      self.assign_attributes r.slice('nick_name', 'head_img', 'user_name', 'principal_name', 'qrcode_url', 'business_info')
      self.alias_name = r['alias']
      self.service_type = r.dig('service_type_info', 'id')
      self.verify_type = r.dig('verify_type_info', 'id')
      self.save
    end

    def store_access_token(r)
      self.access_token = r['authorizer_access_token']
      self.access_token_expires_at = Time.current + r['expires_in'].to_i
      self.refresh_token = r['authorizer_refresh_token']
      self.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') } if r['func_info'].is_a?(Array)
      self.save
    end

  end
end
