class ProgramNotice < WechatNotice
  include RailsWechat::WechatNotice::ProgramNotice
end unless defined? ProgramNotice
