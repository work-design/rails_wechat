class VoiceService < WechatService
  include RailsWechat::WechatService::VoiceService
end unless defined? VoiceService
