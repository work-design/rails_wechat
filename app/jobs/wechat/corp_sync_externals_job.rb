module Wechat
  class CorpSyncExternalsJob < ApplicationJob

    def perform(corp_user)
      corp_user.sync_externals
    end

  end
end
