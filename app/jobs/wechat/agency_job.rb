module Wechat
  class AgencyJob < ApplicationJob

    def perform(agency)
      agency.get_webview_file!
    end

  end
end
