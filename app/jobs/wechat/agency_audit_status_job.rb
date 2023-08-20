module Wechat
  class AgencyAuditStatusJob < ApplicationJob

    def perform(agency)
      agency.get_audit_status!
    end

  end
end
