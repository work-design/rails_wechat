module Wechat
  class SessionLoginChannel < ApplicationCable::Channel

    def subscribed
      stream_from "wechat:session_login:#{session_id}"
    end

  end
end
