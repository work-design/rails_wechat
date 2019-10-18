module RailsWechat::OauthUser::WechatProgramUser
  extend ActiveSupport::Concern
  included do
    attribute :provider, :string, default: 'wechat_program'
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :app_id
  end

  def get_phone_number(encrypted_data, iv, session_key)
    @wechat_app = WechatApp.find_by(appid: current_authorized_token.oauth_user.app_id)

    phone_number = @wechat_app.get_phone_number(params[:encrypted_data], params[:iv], session_key)


    r = Wechat::Cipher.program_decrypt(encrypted_data, iv, session_key)
    r['phoneNumber']
  end
  
end
