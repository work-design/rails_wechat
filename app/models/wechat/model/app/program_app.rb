module Wechat
  module Model::App::ProgramApp

    def template_messenger(template)
      Wechat::Message::Template::Program.new(self, template)
    end

    # 小程序
    def sync_templates
      api.templates.each do |template|
        template = templates.find_or_initialize_by(template_id: template['priTmplId'])
        template.template_type = template['type']
        template.assign_attributes template.slice('title', 'content', 'example')
        template.save
      end
    end

  end
end
