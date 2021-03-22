# frozen_string_literal: true
module Wechat
  class NoticeSendJob < ApplicationJob

    def perform(notice)
      notice.do_send
    end

  end
end
