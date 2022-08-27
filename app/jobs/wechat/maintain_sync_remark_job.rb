module Wechat
  class MaintainSyncRemarkJob < ApplicationJob

    def perform(maintain)
      maintain.sync_remark_to_api
    end

  end
end

