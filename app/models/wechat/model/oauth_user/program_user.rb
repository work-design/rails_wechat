module Wechat
  module Model::OauthUser::ProgramUser
    extend ActiveSupport::Concern

    included do
      attribute :provider, :string, default: 'wechat_program'

      belongs_to :app, foreign_key: :appid, primary_key: :appid
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

    def get_authorized_token(session_key = nil)
      authorized_token = authorized_tokens.order(expire_at: :desc).first
      if authorized_token
        if authorized_token.verify_token?
          authorized_token
        else
          authorized_token.session_key ||= session_key
          authorized_token.update_token!
        end
      else
        authorized_tokens.create(session_key: session_key)
      end
    end

    def auth_token(session_key = nil)
      get_authorized_token(session_key).token
    end

  end
end
