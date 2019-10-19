module RailsWechat::OauthUser::WechatProgramUser
  extend ActiveSupport::Concern
  included do
    attribute :provider, :string, default: 'wechat_program'
    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid
    
    after_save :sync_to_user, if: -> { saved_change_to_name? || saved_change_to_avatar_url? }
  end

  def get_phone_number(encrypted_data, iv, session_key)
    r = Wechat::Cipher.program_decrypt(encrypted_data, iv, session_key)
    r['phoneNumber']
  end
  
  def sync_to_user
    if user
      user.name ||= self.name
      user.avatar.url_sync self.avatar_url unless user.avatar.attached?
      user.save
    end
  rescue
    
  end
  
end
