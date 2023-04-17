module Wechat
  module Model::App::ProgramApp
    extend ActiveSupport::Concern

    included do
    end

    def api
      return @api if defined? @api
      if secret.present?
        @api = Wechat::Api::Program.new(self)
      elsif agency
        @api = Wechat::Api::Program.new(agency)
      else
        raise 'Must has secret or under agency'
      end
    end

    def template_messenger(template)
      Wechat::Message::Template::Program.new(self, template)
    end

    def set_webview_domain(action: 'set')
      api.webview_domain(action: action, webviewdomain: [URI::HTTPS.build(host: domain).to_s])
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
