module Wechat
  module Model::OauthUser::ProgramUser
    extend ActiveSupport::Concern

    included do
      attribute :provider, :string, default: 'wechat_program'
      belongs_to :app, foreign_key: :app_id, primary_key: :appid
    end

    def get_phone_number(encrypted_data, iv, session_key)
      r = Wechat::Cipher.program_decrypt(encrypted_data, iv, session_key)
      if r['phoneNumber']
        r['phoneNumber']
      else
        self.errors.add :base, "手机号获取失败，session_key 为：#{session_key}"
        nil
      end
    end

  end
end
