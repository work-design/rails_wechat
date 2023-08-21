# frozen_string_literal: true

module Wechat
  module Model::App::ProgramAgency
    extend ActiveSupport::Concern

    included do
      attribute :auditid, :integer
      attribute :version_info, :json, default: {}

      enum audit_status: {
        success: 0,
        rejected: 1,
        verifying: 2,
        regretted: 3,
        verify_later: 4
      }, _prefix: true

      belongs_to :platform_template, optional: true

      after_save_commit :get_version_info_later, if: -> { saved_change_to_platform_template_id? }
    end

    def disabled_func_infos
      return unless platform.program_agency
      platform.program_agency.func_infos - func_infos
    end

    def set_nickname
      api.set_nickname(organ.name_short, license: organ.license)
    end

    def set_category(first, second)
      r = {
        first: first,
        second: second
      }
      api.add_category([r])
    end

    def set_webview_domain(action: 'set')
      h = {
        action: action,
        webviewdomain: [URI::HTTPS.build(host: domain).to_s]
      }
      api.webview_domain_directly(**h)
      api.webview_domain(**h)
    end

    def set_domain(action: 'set')
      h = {
        action: action,
        requestdomain: [URI::HTTPS.build(host: domain).to_s],
        wsrequestdomain: [URI::WSS.build(host: domain).to_s],
        uploaddomain: [URI::HTTPS.build(host: domain).to_s],
        downloaddomain: [URI::HTTPS.build(host: domain).to_s],
        udpdomain: [URI::Generic.build(host: domain, scheme: 'udp').to_s],
        tcpdomain: [URI::Generic.build(host: domain, scheme: 'tcp').to_s]
      }
      api.modify_domain_directly(**h)
      api.modify_domain(**h)
    end

    def commit(platform_template)
      r = api.commit(
        template_id: platform_template.template_id,
        user_version: platform_template.user_version,
        user_desc: platform_template.user_desc,
        ext_json: {
          extAppid: appid,
          ext: { host: URI::HTTPS.build(host: domain).to_s }
        }.to_json
      )
      if r['errcode'] == 0
        self.platform_template = platform_template
        self.save
      end
      r
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

      if r['auditid']
        au = api.audit_status(r['auditid'])
        self.auditid = r['auditid']
        self.audit_status = au['status']
        self.save
      end

      r
    end

    def get_audit_status_later
      AgencyAuditStatusJob.perform_later(self)
    end

    def get_audit_status!
      r = api.audit_status(auditid)
      self.audit_status = r['status']
      self.save
      r
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

    def submittable?
      version_info.dig('release_info', 'release_version') != version_info.dig('exp_info', 'exp_version')
    end

    def experienceable?
      audit_status.nil? && submittable?
    end

    def releasable?
      audit_status_success? && submittable?
    end

    def get_version_info!
      r = api.version_info
      self.version_info = { exp_info: r['exp_info'], release_info: r['release_info'] }
      self.version_info['exp_info']['exp_time'] = Time.at(version_info['exp_info']['exp_time']) if version_info['exp_info']
      self.version_info['release_info']['release_time'] = Time.at(version_info['release_info']['release_time']) if version_info['release_info']
      self.save
      self.version_info
    end

    def get_version_info_later
      AgencyVersionJob.perform_later(self)
    end

    def sync_categories
      r = api.categories
      r.each do |cate|
        category = Category.find_or_initialize_by(id: cate['id'])
        category.assign_attributes cate.slice('name', 'level', 'scope')
        category.kind = cate['type']
        category.parent_id = cate['father']
        category.extra = cate
        category.save
      end
    end

  end
end
