module Wechat
  module Model::Service::MpnewsService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'mpnews'
    end

  end
end
