module Wechat
  module Model::App::ProgramApp
    extend ActiveSupport::Concern

    included do
      attribute :auditid, :integer
      attribute :version_info, :json
    end

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
      if program_user.same_oauth_user
        program_user.auto_link
      else
        program_user.user || program_user.build_user
      end
      program_user
    end

    def template_messenger(template)
      Wechat::Message::Template::Program.new(self, template)
    end

    def set_webview_domain(action: 'set')
      api.webview_domain_directly(
        action: action,
        webviewdomain: [URI::HTTPS.build(host: domain).to_s]
      )
    end

    def set_domain(action: 'set')
      api.modify_domain_directly(
        action: action,
        requestdomain: [URI::HTTPS.build(host: domain).to_s],
        wsrequestdomain: [URI::WSS.build(host: domain).to_s],
        uploaddomain: [URI::HTTPS.build(host: domain).to_s],
        downloaddomain: [URI::HTTPS.build(host: domain).to_s],
        udpdomain: [URI::Generic.build(host: domain, scheme: 'udp').to_s],
        tcpdomain: [URI::Generic.build(host: domain, scheme: 'tcp').to_s]
      )
    end

    def commit(template_id: 2, user_version: 'v1.0.1', user_desc: '常规更新')
      api.commit(
        template_id: template_id,
        user_version: user_version,
        user_desc: user_desc,
        ext_json: {
          extAppid: appid,
          ext: { host: URI::HTTPS.build(host: domain).to_s }
        }.to_json
      )
    end

    def submit_audit!
      categories = api.category['categories']
      cate = categories[0]

      r = api.submit_audit(
        item_list: [{
          first_id: cate['first'],
          first_class: cate['first_name'],
          second_id: cate['second'],
          second_class: cate['second_name']
        }]
      )
      logger.debug "\e[35m  Submit Audit: #{r}  \e[0m"
      self.update auditid: r['auditid']
    end

    def audit_status
      api.audit_status(auditid)
    end

    def set_privacy
      api.set_privacy(
        owner_setting: {
          contact_email: 'contact@one.work',
          notice_method: '通过微信公众号消息'
        },
        setting_list: [
          {
            privacy_key: 'UserInfo',
            privacy_text: '用于个人中心身份确认'
          },
          {
            privacy_key: 'Address',
            privacy_text: '用于电商配送'
          },
          {
            privacy_key: 'PhoneNumber',
            privacy_text: '用于打通多平台用户身份'
          },
          {
            privacy_key: 'BlueTooth',
            privacy_text: '用于支持蓝牙打印机'
          }
        ]
      )
    end

    def set_choose_address
      api.apply_privacy_interface('wx.chooseAddress', '用于电商配送')
    end

    def get_qrcode
      file = api.get_qrcode
      self.qrcode.attach io: file, filename: "qrcode_#{id}"
    end

    def get_version_info!
      r = api.version_info
      self.version_info = { exp_info: r['exp_info'], release_info: r['release_info'] }
      self.version_info['exp_info']['exp_time'] = Time.at(version_info['exp_info']['exp_time']) if version_info['exp_info']
      self.version_info['release_info']['release_time'] = Time.at(version_info['release_info']['release_time']) if version_info['release_info']
      self.save
      self.version_info
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
