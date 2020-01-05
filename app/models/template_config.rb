class TemplateConfig < ApplicationRecord
  include RailsWechat::TemplateConfig
end unless defined? TemplateConfig
