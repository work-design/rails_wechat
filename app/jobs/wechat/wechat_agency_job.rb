module Wechat
  class AgencyJob < ApplicationJob

    def perform(agency)
      agency.store_info
    end

  end
end
