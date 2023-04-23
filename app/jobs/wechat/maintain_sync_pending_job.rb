module Wechat
  class MaintainSyncPendingJob < ApplicationJob

    def perform(maintain)
      maintain.get_pending_id!
    end

  end
end

