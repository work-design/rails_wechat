class ApplicationMailbox < ActionMailbox::Base
  routing /@#{RailsWechat.config.email_domain}/i => :wechat
end unless defiend? ApplicationMailbox
