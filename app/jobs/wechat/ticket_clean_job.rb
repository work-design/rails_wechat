module Wechat
  class TicketCleanJob < ApplicationJob

    def perform(ticket)
      Ticket.where(appid: ticket.appid).where.not(id: ticket.id).delete_all
    end

  end
end
