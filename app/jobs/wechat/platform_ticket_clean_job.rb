module Wechat
  class PlatformTicketCleanJob < ApplicationJob

    def perform(ticket)
      ticket.clean_last
    end

  end
end
