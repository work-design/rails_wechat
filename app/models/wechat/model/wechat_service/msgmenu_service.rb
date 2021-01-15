module Wechat
  module Model::WechatService::MsgmenuService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'msgmenu'
    end

  end
end
