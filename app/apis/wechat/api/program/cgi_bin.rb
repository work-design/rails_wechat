module Wechat::Api
  module Program::CgiBin
    BASE = 'https://api.weixin.qq.com/wxa/'

    def create_wxa_qrcode(path = '/pages/index/index', width = 430)
      r = post 'wxaapp/createwxaqrcode', path: path, width: width, origin: BASE

      if r.is_a?(Tempfile) && defined? Com::BlobTemp
        blob = Com::BlobTemp.new(note: path)
        blob.file.attach io: r, filename: path
        blob.save
      else
        r
      end
    end

  end
end

