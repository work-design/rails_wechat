module Wechat
  module Model::Service::MsgmenuService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'msgmenu'
    end

  end
end
