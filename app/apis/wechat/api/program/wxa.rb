module Wechat::Api
  module Program::Wxa
    BASE = 'https://api.weixin.qq.com/wxa/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
    def msg_sec_check(content)
      post 'msg_sec_check', content: content, base: BASE
    end

    def get_wxacode(path, width = 430)
      post 'getwxacode', path: path, width: width, base: BASE
    end

    def get_wxacode_unlimit(scene, **options)
      p = { scene: scene, **options }

      post 'getwxacodeunlimit', **p, base: BASE
    end

    def generate_url(path = '/pages/index/index', **options)
      post 'generate_urllink', path: path, **options, base: BASE
    end

    def generate_scheme(path: '/pages/index/index', **options)
      p = {
        jump_wxa: {
          path: path,
          **options.slice(:query, :env_version)
        },
        **options.slice(:is_expire, :expire_type, :expire_time, :expire_interval)
      }
      post 'generatescheme', **p, base: BASE
    end

  end
end
