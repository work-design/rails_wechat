module Wechat
  module Model::Corp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string, index: true
      attribute :corp_type, :string
      attribute :subject_type, :string
      attribute :verified_end_at, :datetime
      attribute :square_logo_url, :string
      attribute :user_max, :integer
      attribute :full_name, :string
      attribute :wxqrcode, :string
      attribute :industry, :string
      attribute :sub_industry, :string
      attribute :location, :string
      attribute :auth_corp_info, :json
      attribute :auth_user_info, :json
      attribute :register_code_info, :json
      attribute :agent, :json
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :permanent_code, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :provider, optional: true
    end

    def assign_info(info)
      self.assign_attributes info.slice('access_token', 'permanent_code', 'auth_corp_info', 'auth_user_info')
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token']
      self.agent = info.fetch('auth_info', {}).fetch('agent', [])[0]

      corp_info = info.fetch('auth_corp_info', {})
      self.assign_attributes corp_info.slice('corp_type', 'subject_type')
      self.assign_attributes corp_info.transform_keys(&->(i){ i.delete_prefix('corp_') }).slice('name', 'square_logo_url', 'user_max', 'wxqrcode', 'full_name', 'industry', 'sub_industry', 'location')
      self.verified_end_at = Time.at(corp_info['verified_end_time'])
    end

    def auth_info
      info = provider.api.auth_info(corp_id, permanent_code)
      assign_info(info)
      save
    end

    def refresh_access_token
      info = provider.api.corp_token(corp_id, permanent_code)
      self.access_token = info['access_token']
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token'] && self.access_token_changed?
      self.save
    end

  end
end
