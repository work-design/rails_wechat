module Wechat
  module Model::App::ProgramApp
    extend ActiveSupport::Concern

    included do
      attribute :auditid, :integer
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

    def commit(template_id: 2, user_version: 'v1.0.1', user_desc: '常规更新')
      api.commit(
        template_id: template_id,
        user_version: user_version,
        user_desc: user_desc,
        ext_json: {
          extAppid: appid,
          ext: { host: domain }
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

    def get_qrcode
      file = api.get_qrcode
      self.qrcode.attach io: file, filename: "qrcode_#{id}"
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
