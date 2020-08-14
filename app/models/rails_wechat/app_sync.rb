module RailsWechat::AppSync
  extend ActiveSupport::Concern

  included do
    has_many :wechat_menus, foreign_key: :appid, primary_key: :appid
    has_many :wechat_receiveds, foreign_key: :appid, primary_key: :appid
    has_many :wechat_replies, foreign_key: :appid, primary_key: :appid
    has_many :wechat_requests, foreign_key: :appid, primary_key: :appid
    has_many :wechat_responses, foreign_key: :appid, primary_key: :appid
    has_many :wechat_services, foreign_key: :appid, primary_key: :appid
    has_many :wechat_users, foreign_key: :app_id, primary_key: :appid
  end

  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

  def sync_from_menu

  end

end
