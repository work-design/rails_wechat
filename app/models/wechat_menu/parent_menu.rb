class ParentMenu < WechatMenu
  include RailsWechat::WechatMenu::ParentMenu
end unless defined? ParentMenu
