module Wechat::Api::Public::Mp
  BASE = 'https://mp.weixin.qq.com/cgi-bin/'

  def qrcode(ticket)
    get 'showqrcode', params: { ticket: ticket }, as: :file, base: BASE
  end

end
