module Wechat
  class MaintainSyncRemarkJob < ApplicationJob

    def perform(maintain)
      maintain.get_pending_id!
    end

  end
end

