# frozen_string_literal: true

module Wechat
  module Inner::Agent

    def api
      return @api if defined? @api
      @api = WorkApi.new(self)
    end

    def generate_corp_user(code)
      result = api.auth_user(code)
      logger.debug "\e[35m  corp generate user: #{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(userid: result['userid'])
      corp_user.organ = organ

      if result['user_ticket']
        corp_user.user_ticket = result['user_ticket']
        corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
      end

      corp_user.save
      logger.debug "\e[35m  err: #{corp_user.error_text}"
      corp_user
    end

    def get_external_userid(unionid, openid, subject_type: 1)
      api.external_userid(unionid: unionid, openid: openid, subject_type: subject_type)
    end

  end
end
