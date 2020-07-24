module RailsWechat::WechatAgency
  extend ActiveSupport::Concern

  included do
    attribute :appid, :string
    attribute :access_token, :string
    attribute :access_token_expires_at, :datetime
    attribute :refresh_token, :string
    attribute :func_infos, :string, array: true

    belongs_to :wechat_platform
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
  end

end
