class MpnewsService < WechatService
  include RailsWechat::WechatService::MpnewsService
end unless defined? MpnewsService
