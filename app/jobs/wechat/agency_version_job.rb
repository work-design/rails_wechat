module Wechat
  class AgencyVersionJob < ApplicationJob

    def perform(agency)
      agency.get_version_info!
    end

  end
end
