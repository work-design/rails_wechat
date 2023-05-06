module Wechat
  module Inner::Token
    extend ActiveSupport::Concern

    included do
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
    end

    def refresh_access_token
      r = api.token
      if r['access_token']
        self.access_token = r['access_token']
        self.access_token_expires_at = Time.current + r['expires_in'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

  end
end
