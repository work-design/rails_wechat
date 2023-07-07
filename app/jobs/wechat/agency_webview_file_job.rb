module Wechat
  class AgencyWebviewFileJob < ApplicationJob

    def perform(agency)
      agency.store_info!
    end

  end
end
