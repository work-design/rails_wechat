module Wechat::Api
  module Work::Media
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/media/'

    def uploadimg
      post_file 'uploadimg'
    end

  end
end

