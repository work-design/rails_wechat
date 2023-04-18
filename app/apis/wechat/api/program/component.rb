module Wechat::Api
  module Program::Component
    BASE = 'https://api.weixin.qq.com/cgi-bin/component/'

    def privacy_setting(privacy_ver = 2)
      post 'getprivacysetting', privacy_ver: privacy_ver, origin: BASE
    end

    def set_privacy(**options)
      post 'setprivacysetting', **options, origin: BASE
    end

  end
end

