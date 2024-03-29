module Wechat
  module Model::OauthUser::ProgramUser
    extend ActiveSupport::Concern

    included do
      attribute :provider, :string, default: 'wechat_program'
      attribute :session_key, :string
    end

    def get_phone_number!(params)
      r = Wechat::Cipher.program_decrypt(params[:encryptedData], params[:iv], session_key)
      logger.debug "\e[35m  Get Phone Number: #{r}  \e[0m"
      if r['phoneNumber']
        self.identity = r['phoneNumber']
        self.save
      else
        self.errors.add :base, "手机号获取失败，session_key 为：#{session_key}"
        nil
      end
    end

    def skip_auth
      identity.present?
    end

    def only_auth
      false
    end

  end
end
