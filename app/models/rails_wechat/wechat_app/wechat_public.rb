module RailsWechat::WechatApp::WechatPublic
  extend ActiveSupport::Concern
  included do

  end

  def sync_wechat_templates
    templates = api.templates
    templates.each do |template|
      wechat_template = wechat_templates.find_or_initialize_by(template_id: template['template_id'])
      wechat_template.assign_attributes template.slice('title', 'content', 'example')
      wechat_template.save
    end
  end


end
