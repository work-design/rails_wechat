class Wechat::PublicApi
  module Mp
    BASE = 'https://mp.weixin.qq.com/cgi-bin/'

    def qrcode(ticket)
      get 'showqrcode', params: { ticket: ticket }, as: :file, origin: BASE
    end

  end
end
