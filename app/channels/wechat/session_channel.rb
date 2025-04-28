module Wechat
  class SessionChannel < ApplicationCable::Channel

    def subscribed
      stream_from "wechat:session:#{session_id}"
    end

  end
end
