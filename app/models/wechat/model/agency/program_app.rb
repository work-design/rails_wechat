module Wechat
  module Model::Agency::ProgramApp

    def api
      return @api if defined? @api
      @api = Wechat::Api::Program.new(self)
    end

    def domain
      organ&.mp_host
    end

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
