module Wechat::Api
  module Program::Wxa
    BASE = 'https://api.weixin.qq.com/wxa/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
    def msg_sec_check(content)
      post 'msg_sec_check', content: content, base: BASE
    end

    def get_wxacode(path = '/pages/index/index', **options)
      path = "#{path}?#{options.delete(:query).to_query}" if options.key?(:query)
      r = post 'getwxacode', path: path, **options, base: BASE

      if r.is_a?(Tempfile) && defined? Com::BlobTemp
        blob = Com::BlobTemp.new(note: path)
        blob.file.attach io: r, filename: path
        blob.save
      end

      r
    end

    def get_wxacode_unlimit(scene, **options)
      p = { scene: scene, **options }

      post 'getwxacodeunlimit', **p, base: BASE
    end

    def generate_url(path = '/pages/index/index', **options)
      post 'generate_urllink', path: path, **options, base: BASE
    end

    def generate_short(path = '/pages/index/index', **options)
      post 'genwxashortlink', page_url: path, **options, base: BASE
    end

    def generate_scheme(path = '/pages/index/index', **options)
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
