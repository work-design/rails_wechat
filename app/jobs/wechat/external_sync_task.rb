module Wechat
  class ExternalSyncTaskJob < ApplicationJob

    def perform(external)
      external.sync_related_task
    end

  end
end
