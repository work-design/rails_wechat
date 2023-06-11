module Wechat
  module Model::App::ProgramApp

    def api
      return @api if defined? @api
      if agency
        @api = Wechat::Api::Program.new(agency)
      elsif secret.present?
        @api = Wechat::Api::Program.new(self)
      else
        raise 'Must has secret or under agency'
      end
    end

    def generate_wechat_user(code)
      info = api.jscode2session(code)
      logger.debug "\e[35m  Program App Generate User: #{info}  \e[0m"

      program_user = ProgramUser.find_or_initialize_by(uid: info['openid'])
      program_user.appid = appid
      program_user.assign_attributes info.slice('unionid', 'session_key')
      program_user.init_user
      program_user
    end

    def template_messenger(template)
      Wechat::Message::Template::Program.new(self, template)
    end

    def get_qrcode
      file = api.get_qrcode
      self.qrcode.attach io: file, filename: "qrcode_#{id}"
    end

    def get_webview_file!
      r = api.webview_domain_file
      self.confirm_name = r['file_name']
      self.confirm_content = r['file_content']
      self.save
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
