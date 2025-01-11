class Wechat::WorkApi
  module Media
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/media/'

    def uploadimg(file, **options)
      post_file 'uploadimg', file, origin: BASE, **options
    end

  end
end

