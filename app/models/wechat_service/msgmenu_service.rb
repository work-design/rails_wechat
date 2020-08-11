class MsgmenuService < WechatService
  include RailsWechat::WechatService::MsgmenuService
end unless defined? MsgmenuService
