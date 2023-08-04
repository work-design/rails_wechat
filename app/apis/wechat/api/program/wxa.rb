module Wechat::Api
  module Program::Wxa
    BASE = 'https://api.weixin.qq.com/wxa/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
    def msg_sec_check(content)
      post 'msg_sec_check', content: content, origin: BASE
    end

    def get_wxacode(path = '/pages/index/index', **options)
      path = "#{path}?#{options.delete(:query).to_query}" if options.key?(:query)
      r = post 'getwxacode', path: path, **options, origin: BASE

      if r.is_a?(Tempfile) && defined? Com::BlobTemp
        blob = Com::BlobTemp.new(note: path)
        blob.file.attach io: r, filename: path
        blob.save
        blob.url
      else
        r
      end
    end

    def get_wxacode_unlimit(scene, **options)
      p = { scene: scene, **options }

      post 'getwxacodeunlimit', **p, origin: BASE
    end

    def generate_url(path = '/pages/index/index', **options)
      post 'generate_urllink', path: path, **options, origin: BASE
    end

    def generate_short(path = '/pages/index/index', **options)
      post 'genwxashortlink', page_url: path, **options, origin: BASE
    end

    def generate_scheme(path = '/pages/index/index', **options)
      p = {
        jump_wxa: {
          path: path,
          **options.slice(:query, :env_version)
        },
        **options.slice(:is_expire, :expire_type, :expire_time, :expire_interval)
      }
      post 'generatescheme', **p, origin: BASE
    end

    def webview_domain(**options)
      post 'setwebviewdomain', **options, origin: BASE
    end

    def webview_domain_directly(**options)
      post 'setwebviewdomain_directly', **options, origin: BASE
    end

    def webview_domain_file
      post 'get_webviewdomain_confirmfile', origin: BASE
    end

    def modify_domain(**options)
      post 'modify_domain', **options, origin: BASE
    end

    def modify_domain_directly(**options)
      post 'modify_domain_directly', **options, origin: BASE
    end

    def effective_domain
      post 'get_effective_domain', origin: BASE
    end

    def effective_webview_domain
      post 'get_effective_webviewdomain', origin: BASE
    end

    def commit(**options)
      post 'commit', **options, origin: BASE
    end

    def submit_audit(**options)
      post 'submit_audit', **options, origin: BASE
    end

    def audit_status(auditid)
      post 'get_auditstatus', auditid: auditid, origin: BASE
    end

    def audit_undo
      get 'undocodeaudit', origin: BASE
    end

    def release
      post 'release', origin: BASE
    end

    def version_info
      post 'getversioninfo', origin: BASE
    end

    def get_qrcode
      get 'get_qrcode', origin: BASE
    end

    def privacy_interfaces
      get 'security/get_privacy_interface', origin: BASE
    end

    def apply_privacy_interface(api_name, content)
      post 'security/apply_privacy_interface', api_name: api_name, content: content, origin: BASE
    end

    def latest_audit_status
      get 'get_latest_auditstatus', origin: BASE
    end

    def bind_tester(wechatid)
      post 'bind_tester', wechatid: wechatid, origin: BASE
    end

    def set_nickname(nick_name, **options)
      post 'setnickname', nick_name: nick_name, origin: BASE, **options
    end

  end
end
