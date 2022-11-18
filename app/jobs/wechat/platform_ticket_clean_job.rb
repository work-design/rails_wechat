module Wechat
  class PlatformTicketCleanJob < ApplicationJob

    def perform(ticket)
      PlatformTicket.where(appid: ticket.appid).where.not(id: ticket.id).delete_all
    end

  end
end
