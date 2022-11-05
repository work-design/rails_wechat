module Wechat
  class SuiteTicketCleanJob < ApplicationJob

    def perform(ticket)
      SuiteTicket.where(suite_id: ticket.suite_id, info_type: ticket.info_type).where.not(id: ticket.id).delete_all
    end

  end
end
