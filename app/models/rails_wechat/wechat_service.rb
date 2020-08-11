module RailsWechat::WechatService
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :msgtype, :string
    attribute :value, :string
    attribute :appid, :string
    attribute :open_id, :string
    attribute :body, :json

    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
  end


end
