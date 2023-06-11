# frozen_string_literal: true

module Wechat
  module Model::Agency::ProgramAgency
    extend ActiveSupport::Concern

    included do
      attribute :domain, :string
      attribute :auditid, :integer
      attribute :version_info, :json

      belongs_to :platform_template, optional: true
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Program.new(self)
    end

    def disabled_func_infos
      return unless platform.program_agency
      platform.program_agency.func_infos - func_infos
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
        item_list: [
          {
            first_id: cate['first'],
            first_class: cate['first_name'],
            second_id: cate['second'],
            second_class: cate['second_name']
          }
        ]
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

    def get_version_info!
      r = api.version_info
      self.version_info = { exp_info: r['exp_info'], release_info: r['release_info'] }
      self.version_info['exp_info']['exp_time'] = Time.at(version_info['exp_info']['exp_time']) if version_info['exp_info']
      self.version_info['release_info']['release_time'] = Time.at(version_info['release_info']['release_time']) if version_info['release_info']
      self.save
      self.version_info
    end

  end
end
