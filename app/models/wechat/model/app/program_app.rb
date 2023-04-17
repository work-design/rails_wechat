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

    def set_domain(action: 'set')
      api.modify_domain(
        action: action,
        requestdomain: [URI::HTTPS.build(host: domain).to_s],
        wsrequestdomain: [URI::WSS.build(host: domain).to_s],
        uploaddomain: [URI::HTTPS.build(host: domain).to_s],
        downloaddomain: [URI::HTTPS.build(host: domain).to_s],
        udpdomain: [URI::Generic.build(host: domain, scheme: 'udp').to_s],
        tcpdomain: [URI::Generic.build(host: domain, scheme: 'tcp').to_s]
      )
    end

    def submit_audit
      categories = api.category['categories']
      cate = categories[0]

      api.submit_audit(
        item_list: [{
          first_id: cate['first'],
          first_class: cate['first_name'],
          second_id: cate['second'],
          second_class: cate['second_name']
        }]
      )
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
