module Wechat
  class ProviderOrganJob < ApplicationJob

    def perform(provider_organ)
      provider_organ.compute_open_corpid
    end

  end
end
