module Wechat
  class ProviderTicketCleanJob < ApplicationJob

    def perform(ticket)
      ProviderTicket.where(suite_id: ticket.suite_id).where.not(id: ticket.id).delete_all
    end

  end
end
