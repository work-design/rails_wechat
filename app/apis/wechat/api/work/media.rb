module Wechat::Api
  module Work::Media
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/media/'

    def uploadimg(file, **options)
      post_file 'uploadimg', file, base: BASE, **options
    end

  end
end

