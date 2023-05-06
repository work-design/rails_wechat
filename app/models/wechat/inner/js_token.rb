module Wechat
  module Inner::JsToken
    extend ActiveSupport::Concern

    included do
      attribute :jsapi_ticket, :string
      attribute :jsapi_ticket_expires_at, :datetime
    end

    def jsapi_ticket_valid?
      jsapi_ticket_expires_at.acts_like?(:time) && jsapi_ticket_expires_at > Time.current
    end

    def refresh_jsapi_ticket
      info = api.jsapi_ticket
      self.jsapi_ticket = info['ticket']
      self.jsapi_ticket_expires_at = Time.current + info['expires_in'].to_i if info['ticket'] && self.jsapi_ticket_changed?
      self.save
      info
    end

  end
end
