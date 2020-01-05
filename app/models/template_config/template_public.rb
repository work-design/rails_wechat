class TemplatePublic < TemplateConfig
  include RailsWechat::TemplateConfig::TemplatePublic
end unless defined? TemplatePublic
